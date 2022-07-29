This resource is a Item drop script which upon using any of the given below mentioned phone will initiate a contact with a pilot who will drop a crate from the plane and then you can collect the loot from the crate after it reaches the ground (using target)

- 3 different satellite radio calls russian mafia and drops crate with gun, each satellite has different weapons bind to it.

# Old Preview: https://youtu.be/9tv-na2a8D8

# Dependencies:

* qb-core (latest)
* qb-target
* PolyZone

# How to Install

- Add the images in the folder to your inventory
- Add the below items to qb-core/shared/items.lua

```lua
["goldenphone"]  = {["name"] = "goldenphone", ["label"] = "Golden Satellite Phone",	 ["weight"] = 200, 		["type"] = "item", 		["image"] = "goldenphone.png", 	["unique"] = false, 	["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "A communication device used to contact russian mafia."},

["redphone"]     = {["name"] = "redphone",    ["label"] = "Red Satellite Phone",	 ["weight"] = 200, 		["type"] = "item", 		["image"] = "redphone.png", 	["unique"] = false, 	["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "A communication device used to contact russian mafia."},

["greenphone"] 	 = {["name"] = "greenphone",  ["label"] = "Green Satellite Phone",	 ["weight"] = 200, 		["type"] = "item", 		["image"] = "greenphone.png", 	["unique"] = false, 	["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "A communication device used to contact russian mafia."},
```

* Add `cad-gundrop` to resource folder
* ensure in server.cfg and thats all
