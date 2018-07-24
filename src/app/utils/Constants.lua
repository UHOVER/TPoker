
setmetatable(_G, nil)

--设计分辨率
G_DESIGN_WIDTH = 750
G_DESIGN_HEIGHT = 1334
G_DESIGN_RATIO = G_DESIGN_WIDTH / G_DESIGN_HEIGHT

G_DEVICE_RATIO = display.width / display.height
G_RATION = 640 / 960

G_SURPLUS_H = G_DESIGN_HEIGHT / G_DESIGN_WIDTH * display.width - display.height
G_SURPLUS_MAX_H = 209

ZOR_MAX_WINDOW = 20000

DZ_MASTER_VERSION = false
DZ_VERSION = 'v11.1.0'
UPDATE_VERSION_IN = "V11"
DZ_DEBUG = true

-- 自动登录（永久屏蔽为false）
AUTO_LOGIN = false

-- 游客配置
VISITOR_LOGIN = false
VISITOR_SHOW_MSG = "您当前处于游客模式,需要注册用户才能继续此操作"

--zip包名：V3_201701211501.zip
--大版本更新修改过 config.lua

LEN_CARD = 27
LEN_NAME = 18 	-- 名称长度
LEN_DES = 60 	-- 简介长度


DZ_SMS = ""
ABOUT_US_URL = ""
LICENSE_URL = ""
IMG_PREFIX_URL = "http://oy2anmfq4.bkt.clouddn.com/"
SHARE_URL = ""
DISPLAY_G_NAME = "超级扑克"


require ('network.OPER_CODE')
require ('libs.base64')
require ('libs.jsonStr')
require ('utils.DZFileHandle')

Storage			= require ('utils.Storage')
CppPlat			= require ('platform.CppPlat')
DZChat			= require ('platform.DZChat')
DownRes 		= require ('network.DownRes')
DZTime			= require ('utils.DZTime')
DZSchedule		= require ('utils.DZSchedule')
ViewCtrol		= require ('ui.ViewCtrol')
DZConfig 		= require ('utils.DZConfig')
Error 			= require ('network.Error')
Single 			= require ('utils.Single')
StatusCode 		= require ('utils.StatusCode')
ResLib 			= require ('utils.ResLib')
StringUtils 	= require ('utils.StringUtils')
TouchBack 		= require ('ui.TouchBack')
UIUtil 			= require ('ui.UIUtil')
DZUi 			= require ('ui.DZUi')
DZAction 		= require ('ui.DZAction')
Network 		= require ('network.Network')
XMLHttp 		= require ('network.XMLHttp')
DZWindow 		= require ('ui.DZWindow')
MessageWin 		= require ('ui.MessageWin')
DZPlaySound 	= require ('gambling.DZPlaySound')

-- sqliteDB 		= require ("libs.sqliteDB")
ClubModel 		= require("club.ClubModel")
Bottom  		= require ('main.BottomNode')
LayerManage 	= require ('utils.LayerManage')
Notice 		 	= require("common.Notice")
AddCtrol 		= require("club.AddCtrol")

NewMsgMgr 		= require ('utils.NewMsgMgr')

local Constants = {}


return Constants