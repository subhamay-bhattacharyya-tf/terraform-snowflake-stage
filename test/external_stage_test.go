// File: test/external_stage_test.go
package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestExternalStage tests creating an external stage via the module
// Note: This test requires a valid storage integration to be configured in Snowflake
func TestExternalStage(t *testing.T) {
	t.Parallel()

	// Skip if no storage integration is configured
	storageIntegration := os.Getenv("SNOWFLAKE_STORAGE_INTEGRATION")
	s3Bucket := os.Getenv("SNOWFLAKE_TEST_S3_BUCKET")
	if storageIntegration == "" || s3Bucket == "" {
		t.Skip("Skipping external stage test: SNOWFLAKE_STORAGE_INTEGRATION and SNOWFLAKE_TEST_S3_BUCKET environment variables required")
	}

	retrySleep := 5 * time.Second
	unique := strings.ToUpper(random.UniqueId())
	dbName := fmt.Sprintf("TT_DB_%s", unique)
	schemaName := "PUBLIC"
	stageName := fmt.Sprintf("TT_EXT_STAGE_%s", unique)
	stageURL := fmt.Sprintf("s3://%s/test/%s/", s3Bucket, unique)

	tfDir := "../examples/external-stage"

	stageConfigs := map[string]interface{}{
		"test_external_stage": map[string]interface{}{
			"name":                stageName,
			"database":            dbName,
			"schema":              schemaName,
			"url":                 stageURL,
			"storage_integration": storageIntegration,
			"comment":             "Terratest external stage test",
		},
	}

	tfOptions := &terraform.Options{
		TerraformDir: tfDir,
		NoColor:      true,
		Vars: map[string]interface{}{
			"stage_configs":               stageConfigs,
			"snowflake_organization_name": os.Getenv("SNOWFLAKE_ORGANIZATION_NAME"),
			"snowflake_account_name":      os.Getenv("SNOWFLAKE_ACCOUNT_NAME"),
			"snowflake_user":              os.Getenv("SNOWFLAKE_USER"),
			"snowflake_role":              os.Getenv("SNOWFLAKE_ROLE"),
			"snowflake_private_key":       os.Getenv("SNOWFLAKE_PRIVATE_KEY"),
		},
	}

	// Connect to Snowflake and create test database
	db := openSnowflake(t)
	defer func() { _ = db.Close() }()

	createTestDatabase(t, db, dbName)
	defer dropTestDatabase(t, db, dbName)

	createTestSchema(t, db, dbName, schemaName)

	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	time.Sleep(retrySleep)

	// Verify stage exists
	exists := stageExists(t, db, dbName, schemaName, stageName)
	require.True(t, exists, "Expected stage %q to exist in Snowflake", stageName)

	// Verify stage properties
	props := fetchStageProps(t, db, dbName, schemaName, stageName)
	require.Equal(t, stageName, props.Name)
	require.Contains(t, props.URL, s3Bucket)
	require.Contains(t, props.Comment, "Terratest external stage test")
}
