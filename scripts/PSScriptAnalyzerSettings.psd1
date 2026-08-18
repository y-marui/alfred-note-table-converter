@{
    # These scripts are CLI-style pre-commit hooks, not reusable modules.
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',        # Write-Host is the right tool for user-facing CLI messages here
        'PSUseBOMForUnicodeEncodedFile' # intentionally BOM-less UTF-8, for parity with the bash scripts / git-bash tooling
    )
}
