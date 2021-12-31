# XMPPClass

## XMPP相关类

* XMPPStream

* XMPPReconnect: 自动重连对象

* XMPPAutoPing: 心跳检测

* XMPPRoster: 通讯录功能模块
	* XMPPRosterCoreDataStorage: 通讯录存储管理
	* XMPPUserCoreDataStorageObject: 通讯录好友对象实体

* XMPPMessageArchiving: 聊天模块
	* XMPPMessageArchivingCoreDataStorage: 聊天信息的存储管理类
	* XMPPMessageArchiving_Message_CoreDataObject: 聊天消息实体类
	* XMPPMessageArchiving_Contact_CoreDataObject: 最近联系人实体类

* XMPPvCardTempModule: 个人资料功能模块
	* XMPPvCardTemp: 个人资料内存存储类
	* XMPPvCardCoreDataStorage: 个人资料存储器（自己的和别人的）
	* XMPPvCardCoreDataStorageObject: 个人资料的实体对象

* XMPPvCardAvatarModule: 别人个人资料功能模块 
	* XMPPvCardAvatarCoreDataStorageObject: 别人个人资料实体对象
	* XMPPvCardCoreDataStorage: 个人资料存储器（自己的和别人的）

* XMPPMUC: 群聊功能类
	* XMPPRoom: 聊天室功能类
	* XMPPRoomCoreDataStorage: 群聊数据存储管理类


* XMPPRegistration: 注销与密码修改

