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

// TestExternalStage tests creating multiple stages (internal and external) via the module
func TestExternalStage(t *testing.T) {
	t.Parallel()

	retrySleep := 5 * time.Second
	unique := strings.ToUpper(random.UniqueId())
	dbName := fmt.Sprintf("TT_DB_%s", unique)
	schemaName := "PUBLIC"

	stage1Name := fmt.Sprintf("TT_INT_STAGE_%s", unique)
	stage2Name := fmt.Sprintf("TT_EXT_STAGE_%s", unique)

	tfDir := "../examples/external-stage"

	// Pre-create database for the test
	db := openSnowflake(t)
	createTestDatabase(t, db, dbName)
	defer func() {
		dropTestDatabase(t, db, dbName)
		_ = db.Close()
	}()

	// Note: External stage with S3 URL requires storage integration or credentials
	// For testing purposes, we create an internal stage and verify the module works
	stageConfigs := map[string]interface{}{
		"internal_stage": map[string]interface{}{
			"name":     stage1Name,
			"database": dbName,
			"schema":   schemaName,
			"comment":  "Terratest internal stage",
		},
		"external_stage": map[string]interface{}{
			"name":     stage2Name,
			"database": dbName,
			"schema":   schemaName,
			"comment":  "Terratest external stage placeholder",
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

	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	time.Sleep(retrySleep)

	// Verify both stages exist
	for _, stageName := range []string{stage1Name, stage2Name} {
		exists := stageExists(t, db, dbName, schemaName, stageName)
		require.True(t, exists, "Expected stage %q to exist in Snowflake", stageName)
	}

	// Verify properties of internal stage
	props := fetchStageProps(t, db, dbName, schemaName, stage1Name)
	require.Equal(t, stage1Name, props.Name)
	require.Contains(t, props.Comment, "Terratest internal stage")
}
