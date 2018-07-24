local StatusCode = {}

StatusCode.SNG_HAVE_BET		= -1	--sng没有输光还有筹码

StatusCode.POKER_BACK 		= 0		--扑克背面

StatusCode.PHP_SUCCESS		= 0		--php网络请求成功
StatusCode.SUCCESS 			= 1		--网络请求成功

StatusCode.PHP_UPDATE 		= 500500--版本更新停服
StatusCode.PHP_REFRESH_TOKEN=10000 	-- 刷新token

StatusCode.NO_STATUS 		= -1	--没有状态

StatusCode.SORT 			= 1		--顺序
StatusCode.UN_SORT 			= 2		--逆序
StatusCode.KEY_PM 			= 3		--区分类型
StatusCode.KEY_ARRAY 		= 4		--数组排序
StatusCode.KEY_BET 			= 5		--数组排序


StatusCode.SEAT_NULL 		= 1		--位置空
StatusCode.SEAT_USER 		= 2		--玩家坐下


StatusCode.GAME_STAND 		= 1		--站立
StatusCode.GAME_SEAT 		= 2		--坐下

StatusCode.GAME_START 		= 1		--游戏已经开始
StatusCode.GAME_UNSTART		= 0		--游戏没有开始


--进入游戏1000，与服务器返回值对应 2002、1003
StatusCode.GAME_GIVEUP 		= 0		--弃牌
StatusCode.GAME_LOOK 		= 1		--看牌/让牌
StatusCode.GAME_FOLLOW 		= 2		--跟注
StatusCode.GAME_ADD 		= 3		--加注
StatusCode.GAME_ALLIN 		= 4		--all in
StatusCode.GAME_THINK 		= 5		--思考(没有此状态)
StatusCode.GAME_GAME_ING 	= 6		--游戏中但未喊注(有发牌标示， 没有状态)
StatusCode.GAME_WAIT_ING	= 7		--已经坐下但不在游戏中(没有发牌标示，没有状态)
StatusCode.GAME_DELAY 		= 8		--延迟
StatusCode.GAME_STRADDLE1   = 9     --straddle1倍
StatusCode.GAME_NO_STATUS	= -1	--没有状态：观战


--前端状态
StatusCode.GAME_ADD_12 		= 101		--加注底池1/2
StatusCode.GAME_ADD_23 		= 102		--加注底池2/3
StatusCode.GAME_ADD_11 		= 103		--加注底池1


--与服务器同步游戏回合
StatusCode.GAME_ROUND0 		= 0		--牌池还没有发牌
StatusCode.GAME_ROUND1 		= 1		--翻牌
StatusCode.GAME_ROUND2 		= 2		--转牌
StatusCode.GAME_ROUND3 		= 3		--河牌


--main
StatusCode.HALL_START 		= 1		--大厅快速开始
StatusCode.HALL_SNG 		= 2		--大厅sng
StatusCode.HALL_HUPS 		= 3		--大厅单挑
StatusCode.BUILD_STANDARD 	= 4		--组建标准
StatusCode.BUILD_SNG 		= 5		--组建sng
StatusCode.BUILD_MTT 		= 6		--组建MTT


--亮不亮牌
StatusCode.POKER_NO_SHOW	= 0		--结束后不亮牌
StatusCode.POKER_SHOW 		= 1 	--结束后亮牌

--action
StatusCode.BET_TO_POOL 		= 1		--移动到底池
StatusCode.POOL_TO_WIN		= 2		--移动到赢家


--牌局类型
StatusCode.POKER_SNG 		= 'sng'		--牌局类型sng
StatusCode.POKER_GENERAL	= 'standard'	--牌局类型标准
StatusCode.POKER_MTT 		= 'mtt'
StatusCode.POKER_HEADUP     = 'headup'  

--聊天模式
StatusCode.CHAT_CLUB = 'club'
StatusCode.CHAT_CIRCLE = 'circle'
StatusCode.CHAT_FRIEND = 'friend'


--getGlStatus mtt或 common
StatusCode.GLSTATUS_MTT = 'mtt'
StatusCode.GLSTATUS_COMMON = 'common'


--清除回合数据标示
StatusCode.NO_CLEAR		= 'NO_CLEAR'
StatusCode.END_CLEAR	= 'END_CLEAR'
StatusCode.START_CLEAR	= 'START_CLEAR'
StatusCode.ANTE_CLEAR	= 'ANTE_CLEAR'


StatusCode.DESK_BLUE 	= 'DESK_BLUE'
StatusCode.DESK_GREEN 	= 'DESK_GREEN'
StatusCode.DESK_RED 	= 'DESK_RED'

--牌局信息提示类型
StatusCode.PROMPT_NAME		= 1			--牌局名
StatusCode.PROMPT_ANTE		= 2			--ANTE
StatusCode.PROMPT_BLIND		= 3			--大小盲
StatusCode.PROMPT_UPTIME	= 4			--涨盲时间
StatusCode.PROMPT_CODE		= 5			--分享码
StatusCode.PROMPT_AUTHOR	= 6			--授权带入
StatusCode.PROMPT_INSURE	= 7			--保险
StatusCode.PROMPT_GPS_IP 	= 8			--GPS和IP限制标示
StatusCode.PROMPT_STRADDLE	= 9			--straddle开启标示


--游戏中退出进入那个scene，默认是牌局列表
StatusCode.INTO_MAIN = 1


--保险状态
StatusCode.INSURE_DURING_PURCHASE   = 2		     --购买保险中
StatusCode.INSURE_DURING_CUOPAI	    = 4 			 --搓牌中


--lua调用native方法
StatusCode.NATIVE_TYPE0 		= 0				--通过浏览器打开某个网页
StatusCode.NATIVE_TYPE1 		= 1				--判断GPS是否开启
StatusCode.NATIVE_TYPE2 		= 2				--得到经纬度
StatusCode.NATIVE_TYPE3 		= 3				--统计的渠道号


--mtt盲注级别表 快速或慢速
StatusCode.BLIND_FASE		= 0			--快速盲注表
StatusCode.BLIND_SLOW		= 1			--慢速盲注表

--Device - Game State
--the android,ios call to lua function
StatusCode.GAME_IDEL_STATE = 100
StatusCode.GAME_RECONNECT = 110 --断网重连
StatusCode.GAME_EXITCONNECT = 115--断网
StatusCode.GAME_ENTER_BACK = 120 --进入后台
StatusCode.GAME_ENTER_FORE = 125 --进入前台

return StatusCode