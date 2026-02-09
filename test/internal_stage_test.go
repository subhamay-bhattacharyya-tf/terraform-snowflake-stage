// File: test/internal_stage_test.go
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

// TestInternalStage tests creating an internal stage via the module
func TestInternalStage(t *testing.T) {
	t.Parallel()

	retrySleep := 5 * time.Second
	unique := strings.ToUpper(random.UniqueId())
	dbName := fmt.Sprintf("TT_DB_%s", unique)
	schemaName := "PUBLIC"
	stageName := fmt.Sprintf("TT_INTERNAL_STAGE_%s", unique)

	tfDir := "../examples/internal-stage"

	// Pre-create database for the test
	db := openSnowflake(t)
	createTestDatabase(t, db, dbName)
	defer func() {
		dropTestDatabase(t, db, dbName)
		_ = db.Close()
	}()

	stageConfigs := map[string]interface{}{
		"test_stage": map[string]interface{}{
			"name":     stageName,
			"database": dbName,
			"schema":   schemaName,
			"comment":  "Terratest internal stage test",
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

	exists := stageExists(t, db, dbName, schemaName, stageName)
	require.True(t, exists, "Expected stage %q to exist in Snowflake", stageName)

	props := fetchStageProps(t, db, dbName, schemaName, stageName)
	require.Equal(t, stageName, props.Name)
	require.Contains(t, props.Comment, "Terratest internal stage test")
}
