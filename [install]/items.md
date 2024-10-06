> qb-inventory
```lua
drop_radio  = {
    name = "drop_radio",
    label = "Satellite Radio",
    weight = 500,
    type = "item",
    image = "drop_radio.png",
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = "Anonymous communication device."
},
```

> ox inventory
```lua
["drop_radio"] = {
    label = "Satellite Radio",
    weight = 500,
    stack = true,
    close = true,
    description = "Anonymous communication device.",
    server = {
        export = 'cad-gundrop.useItems'
    }
},
```