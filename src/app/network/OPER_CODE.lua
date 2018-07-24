PROTOCOL_NUM 		= "protocolNum"
ERROR_MSG 			= "errMsg"

PHP_POST 			= 'POST'
PHP_GET 			= 'GET'

--短链接PHP
-- PHP_LOGIN        	= 'login'				--登录
PHP_LOGIN			= 'auth/authenticate'
PHP_REGISTER     	= 'register_code'		--注册
PHP_REGISTER_SURE  	= 'register'			--确认验证码
PHP_REGISTER_PWD 	= 'setLoginpwd' 		--设置密码

PHP_FORGET_PWD		= 'pwd_code'			--忘记密码输入手机号获取验证码
PHP_FORGET_SURE_PWD	= 'pwd_code_judge'		--忘记密码了输入验证码确认
PHP_FORGET_SET_PWD  = 'pwd_change'          --忘记密码修改密码

PHP_FIRST_SET 		= 'first_setting' 		--注册后设置信息
-- PHP_GET_MSG			= 'get_userinfo'		--获取用户个人信息
PHP_GET_MSG 		= 'auth/me'
PHP_SET_MSG         = 'setting'             --编辑个人资料


PHP_CLUB_INDEX      = 'club_index'          -- 俱乐部创建
PHP_CHECK_CLUB 		= 'check_create_club' 	-- 检查是否能创建俱乐部
PHP_CLUB_LIST 		= 'clublist'			-- 与我相关俱乐部列表
PHP_CLUB_FIND 		= 'club_search' 		-- 通过俱乐部名片或者id查询俱乐部
PHP_CLUB_DETAIL 	= 'club_detail' 		-- 俱乐部详细信息查看
PHP_CLUB_UPDATE 	= 'update_club' 		-- 俱乐部信息修改
PHP_CLUB_MESSAGE 	= 'join_message' 		-- 发送加入俱乐部申请消息接口
PHP_CLUB_JOIN 		= 'user_join' 			-- 用户加入俱乐部接口
PHP_CLUB_MSG 		= 'club_message' 		-- 俱乐部消息
PHP_CLUB_MEMBER 	= 'club_user_list' 		-- 俱乐部成员
PHP_MEMBER_DELETE	= 'delete_club_user' 	-- 俱乐部成员删除


PHP_FRIEND_SEARCH 	= 'select_users' 		-- 搜索好友
PHP_FRIEND_TEST 	= 'apply_friend'		-- 添加好友发送验证信息
PHP_FRIEND_AGREE 	= 'agree_friend' 		-- 同意好友请求
PHP_FRIEND_LIST 	= 'friend_list' 		-- 获取好友列表

--主页
PHP_ENTER_GAME		= 'enterGame'			--进入牌局
PHP_CREATE_GAME		= 'createGame'			--创建牌局
PHP_START_GAME 		= 'startGame'			--开始游戏

PHP_QUICK_GAME		= 'general/quick_join'	--大厅快速游戏
PHP_HALL_SNG		= 'sng/quick_join'		--大厅sng
PHP_HALL_HEAD_UP    = 'heads_up/quick_join'	--大厅单挑
PHP_GAME_LIST		= 'game_hall/game_list'	--查看全部游戏


--商店
PHP_SHOP_TRADE		= 'createTrade'			--商店交易
PHP_ALL_DIAMOND		= 'returnAllDiamond'	--所有砖石


--聊天
PHP_GET_CHAT_MSG	= 'checkRelationship'	--聊天信息

--ios
PHP_EXIT_GAME		= 'exitGame'			--退出或解散游戏


--sng
PHP_SNG_APPLY		= 'sngApply' 			--报名sng
PHP_SNG_APPLY_LIST	= 'sngApplyList' 		--查看sng申请列表
PHP_SNG_APPLY_CHECK	= 'sngApplyCheck' 		--sng报名房主同意或拒绝
PHP_SNG_LEAVE_GAME	= 'sngLeaveGame'		--sng离开游戏


--成绩
PHP_PERSONAL_STATS	= 'personalStats'		--数据统计
PHP_PERSON_RECORD	= 'personRecord'		--战绩统计
PHP_PERSON_RECORD_DETAIL = 'personRecordDetail' --战绩详情


--客户端log
PHP_CLIENT_LOGS		= 'recordClientErrLog'
PHP_GET_LOGS		= 'readClientErrLog'
PHP_SHARE			= 'share'

--审核&统计
PHP_AUDIT_RECORD_LIST = 'auditRecordList' --审核记录
PHP_GET_ALL_ADMIN = 'getAllTableManager'
PHP_AUDIT_RECORD_DETAIL = 'auditRecordDetail'

PHP_CLUB_STATSITIC = 'unionShareClubStats'

PHP_USER_INSURACE_VAL  = 'uShareInceUserList'


--联盟部分
PHP_UNION_DETAIL = "detail_union"						--联盟详情
PHP_UNION_RACES = "uniongamelist"						--联盟牌局
PHP_UNION_STATICTIS = "unionGameStatistics"					--联盟统计
PHP_UNION_ADMIN_LIST = "unionmanagerslist" 				--联盟管理员列表
php_UNION_DEL_ADMIN = "delunionmanager" 		 		--删除联盟管理
PHP_UNION_DETAIL_FROM_CLUB = "fromclubuniondetail"		--联盟详情 from俱乐部
PHP_UNION_SEARCH_USER = "searchplayers"			 		--搜索用户
PHP_UNION_ADD_ADMIN = "addunionmanagers"		 		--添加联盟管理员
PHP_UNION_SET_ADMIN_AUTH = "setunionmanagersauth"  		--设置联盟管理员权限
PHP_UNION_GET_ADMIN_AUTH = "getunionmanagersauth"		--获取联盟管理员权限
PHP_UNION_GET_CLUB_INFO = "unionclubdetail"				--联盟俱乐部信息获取
PHP_UNION_SET_CLUB_INFO = "updateunionclubinfo"			--联盟俱乐部信息更新
PHP_UNION_DEL_CLUB = "union_del_club"					--删除联盟俱乐部
PHP_UNION_FOCE_STANDUP = "foceuserstandup"				--强制用户站起
PHP_UNION_DISSOVE = "del_union"							--删除联盟

PHP_UNION_RACE_RECORD = "unioncombatgains"				--牌局记录
PHP_CLUB_RACE_RECORD = "fromclubunioncombatgains"  		--俱乐部牌局的记录

PHP_UNION_CREATE_RACE_CHECK = "judgeunionmagrhasauth"   --联盟中创建牌局的检查
PHP_UNION_DELETE_RACES = "delhistorypokerraces" 	  	--删除历史牌局

PHP_UNION_RECORD_GID = "getunionrecordforclub" 			--查看俱乐部战绩
PHP_CLUB_RECORD_GID = "fromclubunioncombatgainslist"

PHP_UNION_RECORD_DETAIL_GID = "getrecordforclubdetail"  --查看联盟俱乐部战绩详情
PHP_CLUB_RECORD_DETAIL_GID = "fromclubunioncombatgainsldl"--查看单个俱乐部战绩详情

PHP_UNION_RECORD_TIME = "getunionrecordforclubbytime" 	--查看一段时间范围内的联盟战绩
PHP_CLUB_RECORD_TIME = "getfromclubunionrecordatabytime" --俱乐部中按时间查询战绩

PHP_UNION_RECORD_DETAIL_TIME = "getrecorddetailaboutgame" --查看一段时间发内内的联盟战绩详情
PHP_CLUB_RECORD_DETAIL_TIME = "getfromclubuniongamebytimedetail"--查看一段时间内的俱乐部战绩-详情

PHP_UNION_SETTLED_UNION  = "settlementForUnion"		--账户结算为联盟
PHP_UNION_SETTLED_CLUB = "settlementForClub"  		--账户结算为俱乐部
--

--游戏中 WS
WS_LINK_PING		= 1				--连接核查
WS_INIT_LINK		= 888			--初始化连接socket
WS_INTO_GAME 		= 1000			--进入游戏
WS_PLAYER_SEAT 		= 1001			--玩家坐下
WS_START_GAME 		= 1002			--开始游戏
WS_BET_SELECT 		= 1003			--押注选择
WS_STAND_LOOK 		= 1004			--站起围观游戏
WS_EXIT_GAME 		= 1005			--退出游戏
WS_STOP_GAME 		= 1006			--暂停游戏
WS_SEND_EMOJI 		= 1007			--发送表情
WS_GET_SURPLUS_TIME	= 1008			--房间剩余时间
WS_SHOW_CARD		= 1009			--结束时是否展示手牌
WS_REAL_TIME		= 1010			--游戏中实时战况
WS_SUPPLEMENT_SCORE	= 1011			--坐下时候才能调用补充记分牌
WS_GOON_GAME		= 1012			--继续游戏
WS_LOOK_APPLAY_LIST	= 1013			--查看记分牌申请列表
WS_AGREE_REFUSE		= 1014			--房主同意或拒绝
WS_APPLAY_CHAGE		= 1015			--更改授权带入

--sng
WS_CANCEL_TRUSTEESHIP = 1016		--sng取消托管

WS_LOOK_HISTORY		= 1017			--回顾历史
WS_COLLECTION_POKER	= 1018			--收藏牌铺
WS_PLAYER_MSG		= 1019			--玩家信息
WS_REQUEST_DELAY	= 1020			--请求延迟
WS_SEND_ANIMATION	= 1021			--发送动画

WS_MTT_REWARD		= 1022			--MTT奖励规则
WS_MTT_BUY_SCORE	= 1024			--MTT重购增购弃购记分牌
WS_MTT_INTO_GAME	= 1025			--MTT进入比赛请求牌桌id
WS_MTT_MATCH_DATA	= 1027			--MTT赛事数据
WS_MTT_RANK			= 1028			--MTT所有排名

WS_LOOK_LOOK		= 1026			--玩家请求发发看
WS_STRADDLE_MODE_CHANGE = 1050   	--房主房间变化
WS_STRADDLE_CONFIRM = 1051 			--确定straddle的选择
--Insurance
WS_INSURE_UI_CHANGE	= 1101			--购买保险的界面变化
WS_INSURE_TODO_CARD = 1102 			--请求搓牌
WS_INSURE_TO_BUY	= 1103			--购买保险
WS_INSURE_CARD_POINT= 1104			--搓牌坐标变化
WS_INSURE_SHOW_CARD = 1105			--展示牌,亮牌


--广播 BRO
BRO_PLAYER_SEAT 	= 2000			--有玩家坐下
BRO_SEND_CARDS		= 2001			--服务器发两张牌给玩家
BRO_PLAYER_SELECT	= 2002			--玩家选择如：弃牌、跟注
BRO_SEND_POOL		= 2003			--向牌池发牌
BRO_STAND_LOOK		= 2005			--玩家站起围观
BRO_ROUND_RESULT	= 2007			--回合结果
BRO_SEND_EMOJI		= 2008			--发送表情
BRO_HOME_CLOSE		= 2009			--房间关闭
BRO_USER_INTO		= 2010			--玩家进入游戏
BRO_USER_EXIT		= 2011			--玩家离开游戏
BRO_PAUSE_GAME		= 2012			--暂停游戏
BRO_GOON_GAME		= 2013			--继续游戏
BRO_APPLAY_SCORES	= 2014			--申请补充记分牌
BRO_ADD_SCORES		= 2015			--有玩家补充记分牌
BRO_APPLAY_REFUSED	= 2016			--申请补充记分牌被拒
BRO_APPLAY_AGREE	= 2017			--申请补充记分牌通过
BRO_NO_APPLAY		= 2018			--没有补充记分牌的申请了
BRO_APPLAY_CHANGE	= 2019			--房间控制带入变更
BRO_CHECK_BET		= 2020			--校验记分牌
BRO_UP_BLIND		= 2021			--升盲广播
BRO_TRUSTEESHIP		= 2022			--是否托管
BRO_ADD_THINK_TIME	= 2023			--玩家增加思考时间
BRO_ANIMATION		= 2024			--动画表情
BRO_RESET_TIME		= 2025			--点击开始后重新核查时间
BRO_DIS_CARD		= 2026			--显示玩家手牌

BRO_MTT_REST		= 2027			--中场或决赛休息倒计时
BRO_MTT_REVIVE		= 2028			--mtt玩家重购提示
BRO_MTT_OVER		= 2029			--mtt玩家被淘汰结束mtt牌局通知
BRO_MTT_DESK		= 2030			--mtt拆桌合桌提示
BRO_CLOSE_ROOM		= 2031			--游戏房间关闭

BRO_LOOK_LOOK		= 2032			--发发看广播

BRO_PLAYER_RANK		= 2033			--玩家排名
BRO_REMOVE_MTT_REST = 2034			--移除中场或决赛休息倒计时

BRO_UPDATE_BUY_TIMES= 2035			--mtt牌局更新玩家已经增购和重构次数
BRO_INTO_INSURE_MODE= 2101    		--玩家进入保险模式     
BRO_INSURE_PURCHASE = 2102			--轮到某人开始购买保险
BRO_INSURE_UICHANGE = 2103 			--购买保险的界面变化
BRO_INSURE_BUY_END  = 2104			--有人购买了保险
BRO_INSURE_DO_CARD  = 2105  		--进入搓牌界面
BRO_INSURE_CARD_MOVE= 2106			--搓牌坐标变化
BRO_INSURE_FLOP_CARD= 2107			--翻开一张牌
BRO_INSURE_LIGHT_CARD= 2108			--亮牌消息
BRO_ANTE_BET		= 2200			--ante筹码设置

--
BRO_STRADDLE_MODE   = 2050 			--straddle模式切换

--模拟广播
WS_INTO_GAME_BRO		= 10000		--进入游戏返回数据模拟广播发送


--php socket
BRO_PHP_3000			= 3000		--发送好友申请
