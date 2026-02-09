// File: test/helpers_test.go
package test

import (
	"crypto/rsa"
	"crypto/x509"
	"database/sql"
	"encoding/pem"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/snowflakedb/gosnowflake"
	"github.com/stretchr/testify/require"
)

type StageProps struct {
	Name     string
	Database string
	Schema   string
	URL      string
	Type     string
	Comment  string
}

func openSnowflake(t *testing.T) *sql.DB {
	t.Helper()

	orgName := mustEnv(t, "SNOWFLAKE_ORGANIZATION_NAME")
	accountName := mustEnv(t, "SNOWFLAKE_ACCOUNT_NAME")
	user := mustEnv(t, "SNOWFLAKE_USER")
	privateKeyPEM := mustEnv(t, "SNOWFLAKE_PRIVATE_KEY")
	role := os.Getenv("SNOWFLAKE_ROLE")

	// Parse the private key
	block, _ := pem.Decode([]byte(privateKeyPEM))
	require.NotNil(t, block, "Failed to decode PEM block from private key")

	var privateKey *rsa.PrivateKey
	var err error

	// Try PKCS8 first, then PKCS1
	key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		privateKey, err = x509.ParsePKCS1PrivateKey(block.Bytes)
		require.NoError(t, err, "Failed to parse private key")
	} else {
		var ok bool
		privateKey, ok = key.(*rsa.PrivateKey)
		require.True(t, ok, "Private key is not RSA")
	}

	// Build account identifier: orgname-accountname
	account := fmt.Sprintf("%s-%s", orgName, accountName)

	config := gosnowflake.Config{
		Account:       account,
		User:          user,
		Authenticator: gosnowflake.AuthTypeJwt,
		PrivateKey:    privateKey,
	}

	if role != "" {
		config.Role = role
	}

	dsn, err := gosnowflake.DSN(&config)
	require.NoError(t, err, "Failed to build DSN")

	db, err := sql.Open("snowflake", dsn)
	require.NoError(t, err)
	require.NoError(t, db.Ping())
	return db
}

func stageExists(t *testing.T, db *sql.DB, database, schema, stageName string) bool {
	t.Helper()

	q := fmt.Sprintf("SHOW STAGES LIKE '%s' IN SCHEMA %s.%s;", escapeLike(stageName), database, schema)
	rows, err := db.Query(q)
	require.NoError(t, err)
	defer func() { _ = rows.Close() }()

	return rows.Next()
}

func fetchStageProps(t *testing.T, db *sql.DB, database, schema, stageName string) StageProps {
	t.Helper()

	q := fmt.Sprintf("SHOW STAGES LIKE '%s' IN SCHEMA %s.%s;", escapeLike(stageName), database, schema)
	rows, err := db.Query(q)
	require.NoError(t, err)
	defer func() { _ = rows.Close() }()

	cols, err := rows.Columns()
	require.NoError(t, err)

	// Find column indices
	nameIdx, dbIdx, schemaIdx, urlIdx, typeIdx, commentIdx := -1, -1, -1, -1, -1, -1
	for i, col := range cols {
		switch col {
		case "name":
			nameIdx = i
		case "database_name":
			dbIdx = i
		case "schema_name":
			schemaIdx = i
		case "url":
			urlIdx = i
		case "type":
			typeIdx = i
		case "comment":
			commentIdx = i
		}
	}
	require.NotEqual(t, -1, nameIdx, "name column not found in SHOW STAGES output")

	require.True(t, rows.Next(), "No stage found matching %s", stageName)

	// Create slice to hold all column values
	values := make([]interface{}, len(cols))
	valuePtrs := make([]interface{}, len(cols))
	for i := range values {
		valuePtrs[i] = &values[i]
	}

	err = rows.Scan(valuePtrs...)
	require.NoError(t, err)

	// Extract the values we need
	getValue := func(idx int) string {
		if idx == -1 || values[idx] == nil {
			return ""
		}
		if s, ok := values[idx].(string); ok {
			return s
		}
		if b, ok := values[idx].([]byte); ok {
			return string(b)
		}
		return fmt.Sprintf("%v", values[idx])
	}

	return StageProps{
		Name:     getValue(nameIdx),
		Database: getValue(dbIdx),
		Schema:   getValue(schemaIdx),
		URL:      getValue(urlIdx),
		Type:     getValue(typeIdx),
		Comment:  getValue(commentIdx),
	}
}

func createTestDatabase(t *testing.T, db *sql.DB, dbName string) {
	t.Helper()
	_, err := db.Exec(fmt.Sprintf("CREATE DATABASE IF NOT EXISTS %s", dbName))
	require.NoError(t, err)
}

func createTestSchema(t *testing.T, db *sql.DB, dbName, schemaName string) {
	t.Helper()
	_, err := db.Exec(fmt.Sprintf("CREATE SCHEMA IF NOT EXISTS %s.%s", dbName, schemaName))
	require.NoError(t, err)
}

func dropTestDatabase(t *testing.T, db *sql.DB, dbName string) {
	t.Helper()
	_, err := db.Exec(fmt.Sprintf("DROP DATABASE IF EXISTS %s", dbName))
	require.NoError(t, err)
}

func mustEnv(t *testing.T, key string) string {
	t.Helper()
	v := strings.TrimSpace(os.Getenv(key))
	require.NotEmpty(t, v, "Missing required environment variable %s", key)
	return v
}

func escapeLike(s string) string {
	return strings.ReplaceAll(s, "'", "''")
}
