extends Resource

## 版本信息资源
class_name Version

## 主版本号: 当项目功能有较大的变动，比如新增非关联模块或整体架构发生变化时。
@export_range(0, 99) var majar_version: int = 0

## 子版本号: 当项目功能有一定的变动，比如增加权限控制或增加与现有逻辑相关联的功能时。
@export_range(0, 99) var minor_version: int = 1

## 修订号: bug 修复或微小变动
@export_range(0, 999) var patch_number: int = 0

## 版本标识:
## debug 开发调测, 特性验证, 不算正式版本
## alpha 内测, 较多问题, 不向外公布
## beta 公测, 问题较少, 会保持优化
## rc 最终测试版, 基本不会改动, 仅修复一些小bug, 发行前最后一个测试版
## release 正式版本, 面向客户的标准版本
## stable 经过长期验证的稳定版本
@export_enum("debug", "alpha", "beta", "rc", "release", "stable") var version_type: String = "debug"

## 构建时间 格式: 20250316
@export_range(20000101, 20990101) var build_number: int = 20250316


## 返回版本字符串, 格式: 0.1.1_debug-build20240608
func version_str() -> String:
	return "%s.%s.%s_%s-build%s" % [majar_version, minor_version, patch_number, version_type, build_number]


## 返回代表版本大小的数字, 用于程序内部配置/数据结构版本的控制
func version_num() -> int:
	return majar_version * 1000000 + minor_version * 1000 + patch_number
