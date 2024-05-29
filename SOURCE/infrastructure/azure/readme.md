# Synopsis #

Folder for Azure specific reusable artefacts.

## Tips: Yaml ##
* Comments start with `#`
* Don't wrap variables in quotes (eg `a: '${something}'`) if you can invoke the directly without wrapping of any kind, including quotes (eg: `a: something`)
* Use `>` (not `|`) when passing params to the bicep module
* Watch out for spaces around the `=` sign when passing params to modules (see below)
* Watch out for leaving comments within params sent to modules (see below)

```
     parameters: >
            resourceLocationId= "australiacentral" #Not only is there a space after the = but this Comment will cause an error.
            resourceLocationId="australiacentral" 
```
The above translates to unparsable string:
```
            resourceLocationId= "australiacentral" #Not only is there a space after the = but this Comment will cause an error. resourceLocationId="australiacentral"
```

## Tips: Bicep ##
Super picky about syntax:
* DO NOT:
  * Don't forget to add `param` in front of params.
  * use "`"`" (use single quotes only)
  * end lines with "`;`"
  * Don't use `concat('foo','bar',etc...)` if you can string-interpolate
  * Do not leave `param`s unused.
  * Use a `var` or `output` ("'_'") to 'sink' `param`s that are not used.
  * use `#` for commenting (the yaml uses `#`, but bicep uses `//`)
  * Output:
    * If you have conditionally omitted to deploy a resource, you'll need to conditionally render output:
      * eg: `output foo string = (condition)? "bar": ""`
    * If you have to reference a property with a dash in it, have to wrap in square brackets
      * eg: `output stringOutput string = user['user-name']`
    

Scope is important to get right:
* You can define `scope:...` on `module`
* but you can't define them on `resource` (the resource arm won't have a `scope` `param`)
* The scope used when you invoke a bicep from a yaml workflow must match the `targetScope` at the top of the file

* child resources don't use 'scope', they use 'parent':
  * e.g. `parent: sitesModule`  

