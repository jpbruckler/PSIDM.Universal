function Expand-PSIDMTemplate {
    <#
    .SYNOPSIS
        Expand a template using specified patterns and replacement properties.

    .DESCRIPTION
        This function takes a template string, an object with properties, and optionally
        a regex pattern and a hashtable of replacement properties. It uses the patterns
        to find matches in the template and replace them with the corresponding property
        values in the $Context and/or $ReplacementProperties parameters. It also applies
        string functions to the matched properties if specified.

        Tokens in the template must be enclosed in double curly braces ({{ and }}). If
        a function is specified, it must be separated from the property name by a double
        colon (::). If a function parameter is specified, it must be enclosed in square
        brackets ([]). For example, {{FirstName::ToUpper}} will replace the token with
        the value of the FirstName property, converted to uppercase.

        Supported transformation functions are:
            First           - Returns the first N characters of the string
            SkipFirst       - Returns the string with the first N characters removed
            Last            - Returns the last N characters of the string
            SkipLast        - Returns the string with the last N characters removed
            ToLower         - Converts the string to lowercase
            ToUpper         - Converts the string to uppercase
            Trim            - Removes leading and trailing whitespace
            TrimStart       - Removes leading whitespace
            TrimEnd         - Removes trailing whitespace
            Replace         - Replaces a substring with another substring
            RegexReplace    - Replaces a substring with another substring using a regex pattern

    .PARAMETER Template
        The template string to expand.

    .PARAMETER Context
        The object that provides properties for the template expansion.

    .EXAMPLE
        $context = [PSCustomObject]@{
            GivenName = 'John'
            Surname = 'Doe'
            Domain = 'example.com'
        }
        Expand-PSIDMTemplate -Template "{{GivenName}}.{{Surname}}@{{Domain}}" -Context $context
        Outputs: John.Doe@example.com

    .EXAMPLE
        $context = [PSCustomObject]@{
            GivenName = 'John'
            Surname = 'Doe'
        }
        Expand-PSIDMTemplate -Template "{{GivenName::ToUpper}}.{{Surname::ToUpper}}" -Context $context
        Outputs: JOHN.DOE

    .OUTPUTS
        System.String

    .NOTES

    #>
    [CmdletBinding()]
    param (
        [Parameter( Mandatory = $true,
            ValueFromPipeline = $true )]
        [string] $Template,

        [Parameter( Mandatory = $True,
            ValueFromPipeline = $true)]
        [Alias('InputObject')]
        [PSCustomObject] $Context
    )

    begin {
        $Pattern = "(?'token'{{(?'property'\w+)(::(?'func'\w+)(\[(?'param'[\w\d,]+)\])?)?}})"
        $RegEx = [regex]::new($Pattern)
    }

    process {
        $MatchedTokens  = $RegEx.Matches($Template)
        #$Context        = Merge-Object -Objects (Get-IdmSetting -Path Replacements), (Get-IdmSetting -Path UserConfig.Replacements), $Context

        foreach ($hit in $MatchedTokens) {
            # Assign the named matches to variables
            $token = $hit.Groups['token'].Value
            $property = $hit.Groups['property'].Value
            $func = $hit.Groups['func'].Value
            $param = $hit.Groups['param'].Value
            $value = $null

            Write-Debug "token: $token, property: $property, func: $func, param: $param"


            # Check that the Context object has a property with a name
            # matching the value of the token.
            if ($Context.PSObject.Properties.Name -contains $property) {
                $value = $Context.$property
            }
            else {
                Write-Warning "Property $property not found"
            }

            # The expansion function is optional, and is limited to those functions
            # defined in the switch statement below. Since $value will be a string,
            # the template/expansion functions provided here are limited (by choice)
            # to those that can be applied to a string.
            if ($null -ne $func) {
                switch ($func.ToLower()) {
                    'first' {
                        $value = $value.Substring(0, [int]$param)
                    }
                    'skipfirst' {
                        $value = $value.Substring([int]$param)
                    }
                    'last' {
                        $value = $value.Substring($value.Length - [int]$param)
                    }
                    'skiplast' {
                        $value = $value.Substring(0, $value.Length - [int]$param)
                    }
                    'tolower' {
                        $value = $value.ToLower()
                    }
                    'toupper' {
                        $value = $value.ToUpper()
                    }
                    'trim' {
                        $value = $value.Trim()
                    }
                    'trimstart' {
                        $value = $value.TrimStart()
                    }
                    'trimend' {
                        $value = $value.TrimEnd()
                    }
                    'replace' {
                        $value = $value.Replace($param.Split(',')[0], $param.Split(',')[1])
                    }
                    'regexreplace' {
                        $value = $value -replace $param.Split(',')[0], $param.Split(',')[1]
                    }
                }
            }

            $Template = $Template.Replace($token, $value)
        }
        return $Template
    }
}