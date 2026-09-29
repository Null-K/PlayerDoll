# PlayerDoll [English](README_EN.md)
一个基于 **Shader** 实现的玩家皮肤玩偶，无需额外添加皮肤贴图，即可实时显示玩家皮肤。  
同时，你可以通过配置为玩偶添加自定义手持物品，让玩偶呈现更加丰富的效果。

> [!WARNING]  
> ### 不兼容光影包！  
> 玩偶依赖资源包中的自定义 Shader 来实现玩家皮肤渲染。根据 Iris 的 Shader 加载机制，启用光影包后，资源包中的自定义 Shader 将被忽略，并改用光影包提供的 Shader。  
> 由于 PlayerDoll 的实现原理，该限制无法通过配置进行解决。

## 安装

1. 将 PlayerDoll 文件夹整个放入：`plugins/CraftEngine/resources/`
2. 执行 `/ce reload all` 命令重新加载 CraftEngine
3. 安装完成

## 使用

### 获取玩偶
```
/ce item get playerdoll:player_doll
```
拿出的玩偶默认使用**自己的玩家皮肤**。

### 修改玩偶皮肤
手持需要修改的玩偶，执行：
```
/minecraft:item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:profile":"皮肤名称"}}
```
将 `皮肤名称` 替换为需要使用的玩家皮肤名称即可。

### 修改玩偶手中物品
手持需要修改的玩偶，执行：
```
/minecraft:item modify entity @s weapon.mainhand {function:"minecraft:set_custom_model_data",strings:{values:["右手物品","左手物品"],mode:"replace_all"}}
```
其中：
- 第一个值为右手物品
- 第二个值为左手物品

例如：
```
["diamond_sword","shield"]
```

物品名称必须已经在 PlayerDoll 的玩偶配置中注册 `PlayerDoll/configuration/player_doll.yml`

## 兼容性
- 实现版本：Minecraft 26.2
- 需要 CraftEngine 作为前置插件
- 不兼容光影包
- 其他 Minecraft 版本可能存在兼容性问题
