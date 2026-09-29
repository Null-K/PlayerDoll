# PlayerDoll
一个基于 Shader 实现的玩家皮肤玩偶，无需额外添加皮肤贴图，即可实时显示玩家皮肤。

> [!WARNING]  
> 该着色器不兼容光影包！  
> PlayerDoll 依赖资源包中的自定义 Shader 实现玩家皮肤渲染。根据 Iris 的 Shader 加载机制，加载光影包后，资源包中的自定义 Shader 会被忽略，并使用光影包自身的 Shader。

## 安装

1. 将 PlayerDoll 文件夹整个放入：`plugins/CraftEngine/resources/`
2. 使用以下命令重新加载 CraftEngine：`/ce reload all`
3. 安装完成

## 使用

### 获取玩偶
```
/ce item get playerdoll:player_doll
```
拿出的玩偶默认使用自己的玩家皮肤

### 修改玩偶皮肤
```
/minecraft:item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:profile":"皮肤名称"}}
```
手中拿着要修改皮肤的玩偶，将 `皮肤名称` 替换为需要使用的皮肤名称即可。

### 修改玩偶手中物品
```
/item modify entity @s weapon.mainhand {function:"minecraft:set_custom_model_data",strings:{values:["右手物品","左手物品"],mode:"replace_all"}}
```
物品名称必须已经存在于 PlayerDoll 的玩偶配置中 `PlayerDoll/configuration/player_doll.yml`
