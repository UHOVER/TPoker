local ResLib = {}

--扑克牌目录
ResLib.CARD_DIR = 'dzcard/'


--特效
ResLib.DZ_EFFECT = 'dzeffect/'


--csb文件目录
local scene = 'scene/'
ResLib.GAME_CSB 			= scene..'GameScene.csb'
ResLib.GEMOJI_CSB 			= scene..'GEmojiLayer.csb'
ResLib.GMENU_CSB 			= scene..'GMenuLayer.csb'
ResLib.GBUY_CSB 			= scene..'GSureBuy.csb'
ResLib.GPROMPT_CSB 			= scene..'GPromptLayer.csb'
ResLib.GHOME_CSB 			= scene..'GHomeLayer.csb'
ResLib.GSELF_CSB 			= scene..'GSelfLayer.csb'
ResLib.GRESULT_CSB			= scene..'GResult.csb'
-- ResLib.GSNG_RULE_CSB 		= scene..'GSngRule.csb'
ResLib.GSNG_RULE_CSB 		= scene..'GRuleSNG.csb'
ResLib.GPLAYER_MSG_CSB 		= scene..'GPlayerMsg.csb'
ResLib.GREWARD_RULE_CSB		= scene..'GRewardRule.csb'

ResLib.MAIN_CSB 			= scene..'MainScene.csb'
ResLib.ALL_GAME_CSB 		= scene..'AllGame.csb'

ResLib.GWINDOW1_CSB 		= scene..'GMttBuy.csb'
ResLib.GWINDOW2_CSB 		= scene..'GWindow2.csb'
ResLib.MTT_OVER_CSB 		= scene..'GMttOver.csb'

ResLib.GAME_WAIT_CSB 		= scene..'GMttLayer.csb'

ResLib.RESULT_SCENE_CSB		= scene..'ResultScene.csb'
ResLib.RBASE_LAYER_CSB		= scene..'RBaseLayer.csb'
ResLib.RMSG_LAYER_CSB		= scene..'RResultMsg.csb'


ResLib.GAMBLING_CSB			= scene..'Gambling.csb'

ResLib.DZ_WINDOW1			= scene..'DZWindow1.csb'

ResLib.GSETCOLOR_CSB		= scene..'GSetColor.csb'


--公共
local dirCom = 'common/'
ResLib.COM_NO_ANYTHING = dirCom..'no_anything.png'
ResLib.COM_GRAY_9 = dirCom..'com_gray_9.png'
ResLib.BOTTOM_SHADOW = dirCom..'common_bottom_shadow.png'
ResLib.COM_CARD = dirCom..'com_cardbg.png'
ResLib.COM_POKER_LIGHT = dirCom..'com_poker_light.png'
ResLib.COM_ARROW = dirCom..'com_arrow.png'
ResLib.COM_SWITCH3 = dirCom..'com_switch3.png'
ResLib.COM_SWITCH4 = dirCom..'com_switch4.png'
ResLib.COM_TITLE_BG = dirCom..'com_titlebg.png'
ResLib.COM_BTN_BG_1 = dirCom..'com_btn_bg_1.png'
ResLib.COM_BTN_BG_2 = dirCom..'com_btn_bg_2.png'
ResLib.COM_BTN_BG_2_RED = dirCom..'com_btn_bg_2_red.png'
-- ResLib.COM_BTN_BG_PRE = dirCom..'com_btn_bg_pressed.png'

ResLib.COM_OPACITY0 = dirCom..'com_opacity0.png'
ResLib.COM_BLACK = dirCom..'com_black.png'
ResLib.COM_WHITE = dirCom..'com_white.png'
ResLib.COM_EDIT_WHITE = dirCom.."set_card_MTT_edit.png"
ResLib.COM_LIGHT_BTN = dirCom.."com_opacity0.png"
ResLib.COM_SHADE_BTN = dirCom.."com_opacity0.png"

ResLib.TAB_GAME_BTN_S = dirCom.."btn_tab_game_s.png"
ResLib.TAB_GAME_BTN_U = dirCom.."btn_tab_game_u.png"
ResLib.TAB_RECORD_BTN_U = dirCom.."btn_tab_record_u.png"
ResLib.TAB_RECORD_BTN_S = dirCom.."btn_tab_record_s.png"
ResLib.TAB_UNION_BTN_S = dirCom.."btn_tab_union_s.png"
ResLib.TAB_UNION_BTN_U = dirCom.."btn_tab_union_u.png"
ResLib.TAB_TOTAL_BTN_S = dirCom.."btn_tab_total_s.png"
ResLib.TAB_TOTAL_BTN_U = dirCom.."btn_tab_total_u.png"
ResLib.TAB_MSG_BTN_S = dirCom.."btn_tab_msg_s.png"
ResLib.TAB_MSG_BTN_U = dirCom.."btn_tab_msg_u.png"


-- point
ResLib.COM_POINT_RED = dirCom.."com_icon_point_red.png"
ResLib.COM_POINT_RED1 = dirCom.."com_icon_point_red1.png"

ResLib.LOAD_BAR_BG = dirCom..'com_progress_bg_blue.png'
ResLib.LOAD_BAR = dirCom..'com_progress_blue.png'
ResLib.CHECKBOX_BG = dirCom..'checkbox_bg.png'
ResLib.CHECKBOX_DUIHAO = dirCom..'checkbox_duihao.png'
-- btn
ResLib.PHOTO_ADD = dirCom..'com_photo_add.png'
ResLib.PHOTO_ADD_1 = dirCom..'com_photo_add_1.png'
ResLib.BTN_GREEN_NOR = dirCom..'com_btn_green_nor.png'
ResLib.BTN_GREEN_PRE = dirCom..'com_btn_green_pre.png'
ResLib.BTN_GREEN_DIS = dirCom..'com_btn_green_dis.png'
ResLib.BTN_WHITE_NOR = dirCom..'com_btn_white_nor.png'
ResLib.BTN_WHITE_PRE = dirCom..'com_btn_white_pre.png'
ResLib.BTN_WHITE_DIS = dirCom..'com_btn_white_dis.png'
ResLib.BTN_RED_NOR = dirCom..'com_btn_red_nor.png'
ResLib.BTN_RED_PRE = dirCom..'com_btn_red_pre.png'
ResLib.BTN_RED_DIS = dirCom..'com_btn_red_dis.png'
ResLib.BTN_BLUE_BORDER = dirCom..'com_btn_blue_border.png'
ResLib.BTN_BLUE_GREY_BORDER = dirCom..'com_btn_blue_grey_border.png'
ResLib.BTN_BLUE_BORDER_NEW = dirCom..'com_btn_blue_solid.png'
ResLib.BTN_BLUE_BORDER_DIS_NEW = dirCom..'com_btn_blue_solid_dis.png'

ResLib.BTN_BLUE_BORDER_SMALL = dirCom.."com_btn_blue_border_small.png"
ResLib.BTN_BLUE_NOR = dirCom .. "com_btn_blue_nor.png"
ResLib.BTN_BLUE_DIS = dirCom .. "com_btn_blue_dis.png"
ResLib.BTN_BLUE_NOR_NEW = dirCom .. "com_btn_blue_nor_new.png"
ResLib.BTN_BLUE_DIS_NEW = dirCom .. "com_btn_blue_dis_new.png"

-- btn_cell
ResLib.BTN_CELL_ADD = dirCom .. "com_btn_cell_add.png"
ResLib.BTN_CELL_AGREE = dirCom .. "com_btn_cell_agree.png"
ResLib.BTN_CELL_REFUSE = dirCom .. "com_btn_cell_refuse.png"
ResLib.BTN_CELL_INVITE = dirCom .. "com_btn_cell_invite.png"

-- back
ResLib.BTN_BACK = dirCom..'com_btn_back.png'
ResLib.BTN_BACK_RIGHT = dirCom..'com_btn_back_right.png'
-- photo
ResLib.BTN_PHOTO_BOTTOM = dirCom..'com_btn_photo_bottom.png'
ResLib.BTN_PHOTO_MIDDLE = dirCom..'com_btn_photo_middle.png'
ResLib.BTN_PHOTO_TOP = dirCom..'com_btn_photo_top.png'
ResLib.BTN_PHOTO = dirCom..'com_btn_photo.png'
-- 默认相册
ResLib.COM_DEFUALT_PHOTO = dirCom..'com_defualt_photo.png'

-- circle mask
ResLib.MASK_RING_GREY = dirCom .. 'mask_ring_grey.png'
ResLib.MASK_RING_WHITE = dirCom .. 'mask_ring_white.png'

--bg
local mainBg = 'bg/'
ResLib.MAIN_BG =  mainBg ..'bg_main.png'
ResLib.TABLEVIEW_BG = mainBg .. 'bg_main.png'
ResLib.TABLEVIEW_CELL_BG = mainBg .. 'bg_tableview_cell.png'
ResLib.TABLEVIEW_CELL_BG_NOLINE = mainBg .. "bg_tableview_cell_noline.png"
ResLib.TABLEVIEW_CELL_BG_LINE_2 = mainBg .. "bg_tableview_cell_line_2.png"
ResLib.TABLEVIEW_TEXT_LINE = mainBg .. "bg_tableview_text_line.png"
ResLib.IMG_BG = mainBg.."bg_main.png"
ResLib.IMG_LINE_BG = mainBg.."img_line_bg.png"
ResLib.IMG_CELL_BG1 = mainBg.."img_cell_bg1.png"	-- 上下全边线
ResLib.IMG_CELL_BG2 = mainBg.."img_cell_bg2.png"	-- 上半下全边线
ResLib.IMG_CELL_BG2_1 = mainBg.."img_cell_bg2_1.png"-- 上半下无边线
ResLib.IMG_CELL_BG3 = mainBg.."img_cell_bg3.png"	-- 上全下无边线
ResLib.IMG_CELL_GREY_BG = mainBg.."img_cell_grey_bg.png"	-- 上全下无边线

-- MTT
local dirMtt = 'mtt/'
ResLib.MTT_BG = dirMtt..'mtt_intro_bg.png'

--icon
ResLib.ICON_DEF_HEAD = 'icon/icon_boy_default.png'

--游戏中
local dirGame = 'game/'
ResLib.GAME_BG = dirGame..'game_bg.png'
ResLib.GAME_NULL = dirGame..'game_null.png'
ResLib.GAME_BET_ADD1 = dirGame..'game_bet_add1.png'
ResLib.GAME_BET_ADD2 = dirGame..'game_bet_add2.png'
ResLib.GAME_BET_LINE = dirGame..'game_bet_line.png'
ResLib.GAME_BET_THUMB = dirGame..'game_bet_thumb.png'
ResLib.GAME_BET_ALL = dirGame..'game_bet_all.png'
ResLib.GAME_IC_ZONG = dirGame..'game_ic_zong.png'
ResLib.GAME_PROGRESS = dirGame..'game_progress.png'
ResLib.GAME_TAG_D = dirGame..'game_tag_d.png'

ResLib.GAME_ADDS = dirGame..'game_adds.png'
ResLib.GAME_ALLINS = dirGame..'game_allins.png'
ResLib.GAME_LOOKS = dirGame..'game_looks.png'
ResLib.GAME_FOLLOWS = dirGame..'game_follows.png'
ResLib.GAME_BET_TAG = dirGame..'game_chouma_tag.png'

--btn
ResLib.GAME_LOOK_BTN1 = dirGame..'game_look_btn1.png'
ResLib.GAME_LOOK_BTN2 = dirGame..'game_look_btn2.png'
ResLib.GAME_GIVEUP_BTN1 = dirGame..'game_giveup_btn1.png'
ResLib.GAME_GIVEUP_BTN2 = dirGame..'game_giveup_btn2.png'
ResLib.GAME_POOL_BTN1 = dirGame..'game_pool_btn1.png'
ResLib.GAME_POOL_BTN2 = dirGame..'game_pool_btn2.png'
ResLib.GAME_DELAY = dirGame..'game_delay.png'
ResLib.GAME_DELAY_GRAY = dirGame..'game_delay1.png'
ResLib.GAME_DELAY_TIME = dirGame..'game_delay_time.png'
ResLib.GAME_BTN_BIG_BLIND1 = dirGame..'game_bigblind_btn1.png'
ResLib.GAME_BTN_BIG_BLIND2 = dirGame..'game_bigblind_btn2.png'

--俱乐部
local dirClub = 'club/'
ResLib.CLUB_BTN_BG = dirClub..'club_btn_bg.png'
ResLib.CLUB_EDIT_BG = dirClub..'club_edit_bg.png'

ResLib.CLUB_HEAD_GENERAL = dirCom..'defualt_icon_club_general.png'
ResLib.CLUB_HEAD_GENERAL_SMALL = dirCom..'defualt_icon_club_general_small.png'
-- ResLib.CLUB_HEAD_ORIGIN = dirCom..'defualt_icon_club_origin.png'
-- ResLib.CLUB_HEAD_ORIGIN_SMALL = dirCom..'defualt_icon_club_origin_small.png'
ResLib.CLUB_HEAD_ORIGIN = dirCom..'defualt_icon_club_general.png'
ResLib.CLUB_HEAD_ORIGIN_SMALL = dirCom..'defualt_icon_club_general_small.png'

ResLib.CIRCLE_HEAD = dirCom..'defualt_icon_circle.png'
ResLib.CIRCLE_HEAD_SMALL = dirCom..'defualt_icon_circle_small.png'
ResLib.USER_HEAD = dirCom..'defualt_icon_user.png'

ResLib.UNION_HEAD = dirCom.."defualt_icon_union.png"
ResLib.UNION_HEAD_SMALL = dirCom.."defualt_icon_union_small.png"
-- user
ResLib.USER_DEF_HEAD_PNG = dirCom..'defualt_icon_user.png'

-- team
ResLib.TEAM_HEAD = dirCom..'defualt_icon_user.png'

--stencil
ResLib.CLUB_HEAD_STENCIL_200 = dirClub..'club_head_stencil_200.png'

-- 搜索框
ResLib.SEARCH_BTN = dirClub..'search_btn.png'

ResLib.UNION_EDIT_BTN = dirClub..'union_edit_btn.png'
ResLib.UNION_ACTIVE_BTN = dirClub..'union_active_btn.png'
ResLib.UNION_ADMIN_BTN = dirClub..'union_admin_btn.png'
ResLib.UNION_MSG_BTN = dirClub..'union_msg_btn.png'

ResLib.P_ADMIN_BTN_U = dirClub..'primitive_admin_btn_u.png'
ResLib.P_ADMIN_BTN_L = dirClub..'primitive_admin_btn_l.png'
ResLib.M_ADMIN_BTN_U = dirClub..'middle_admin_btn_u.png'
ResLib.M_ADMIN_BTN_L = dirClub..'middle_admin_btn_l.png'
ResLib.H_ADMIN_BTN_U = dirClub..'high_admin_btn_u.png'
ResLib.H_ADMIN_BTN_L = dirClub..'high_admin_btn_l.png'
ResLib.UNION_GAME_START  = dirClub.."union_game_start.png"
ResLib.UNION_GAME_STOP  = dirClub.."union_game_stop.png"

--联盟战绩
ResLib.U_RECORD_CELL_BG = dirClub.."record_cell_bg.png"
ResLib.U_RECORD_CELL_BORDER = dirClub.."record_cell_border.png"
ResLib.U_RECORD_BTN_DOWN = dirClub.."record_detail_btn_down.png"
ResLib.U_RECORD_BTN_UP = dirClub.."record_detail_btn_up.png"

--effect
local dirEffect = 'dzeffect/'
ResLib.EFFECT_VOICE = dirEffect..'game_voice'
ResLib.EFFECT_REFRESH = dirEffect..'pull_refresh'

--游戏中动画
ResLib.EFFECT_HAND 		= dirEffect..'hand_ani'
ResLib.EFFECT_BEER 		= dirEffect..'beer'
ResLib.EFFECT_BOMB 		= dirEffect..'bomb'
ResLib.EFFECT_CAKE 		= dirEffect..'cake'
ResLib.EFFECT_CHICKEN	= dirEffect..'chicken'

-- ResLib.EFFECT_DIAMOND 	= dirEffect..'diamond'
ResLib.EFFECT_FISH 		= dirEffect..'fish'
-- ResLib.EFFECT_FLOWER	= dirEffect..'flower'
ResLib.EFFECT_MOUTH 	= dirEffect..'mouth'
ResLib.EFFECT_REDPACKET	= dirEffect..'redPacket'
ResLib.EFFECT_PANDA		= dirEffect..'panda'

ResLib.EFFECT_STAR		= dirEffect..'starlight'

--赢家动画
ResLib.EFFECT_YOU_WIN	= dirEffect..'anim_youwin'


ResLib.HAND_ONE 	= dirEffect..'hand_dis.png'
ResLib.BEER_ONE 	= dirEffect..'beer_dis.png'
ResLib.BOMB_ONE 	= dirEffect..'bomb_dis.png'
ResLib.CAKE_ONE 	= dirEffect..'cake_dis.png'
ResLib.CHICKEN_ONE 	= dirEffect..'chicken_dis.png'

-- ResLib.DIAMOND_ONE 	= dirEffect..'hand_dis.png'
ResLib.FISH_ONE 	= dirEffect..'fish_dis.png'
-- ResLib.FLOWER_ONE 	= dirEffect..'hand_dis.png'
ResLib.MOUTH_ONE 	= dirEffect..'mouth_dis.png'
ResLib.REDPACKET_ONE= dirEffect..'redPacket_dis.png'
ResLib.PANDA_ONE	= dirEffect..'panda_dis.png'

--灰色
ResLib.HAND_GREY 	= dirEffect..'hand_dis_grey.png'
ResLib.BEER_GREY 	= dirEffect..'beer_dis_grey.png'
ResLib.BOMB_GREY 	= dirEffect..'bomb_dis_grey.png'
ResLib.CAKE_GREY 	= dirEffect..'cake_dis_grey.png'
ResLib.CHICKEN_GREY = dirEffect..'chicken_dis_grey.png'

-- ResLib.DIAMOND_GREY 	= dirEffect..'hand_dis_grey.png'
ResLib.FISH_GREY 	= dirEffect..'fish_dis_grey.png'
-- ResLib.FLOWER_GREY 	= dirEffect..'hand_dis_grey.png'
ResLib.MOUTH_GREY 	= dirEffect..'mouth_dis_grey.png'
ResLib.REDPACKET_GREY= dirEffect..'redPacket_dis_grey.png'
ResLib.PANDA_GREY 	= dirEffect..'panda_dis_grey.png'

local particle = 'particles/'
ResLib.XING_PARTICLE = particle..'xingxing.plist'



---insurance
local BX 				= 'insurance/'
ResLib.BX_CLOSE 		= BX..'close.png'
ResLib.BX_CLOSE_PRESS   = BX..'close_press.png'
ResLib.BUY   			= BX..'buy.png'
ResLib.BUY_PRESS   		= BX..'buy_press.png'
ResLib.BUY_DIS			= BX..'buy_dis.png'
ResLib.GIVE_UP   		= BX..'giveup.png'
ResLib.GIVE_UP_PRESS    = BX..'giveup_press.png'
ResLib.GIVE_UP_DIS    = BX..'giveup_dis.png'
ResLib.SELECT_ALL_NORMAL    = BX..'all.png'
ResLib.SELECT_ALL_SELECTED  = BX..'all.png'
ResLib.SLIDER_TRUCK 	= BX..'slider_truck.png'
ResLib.SLIDER_THUMB 	= BX..'sliderThumb.png'
ResLib.SLIDER_THUMB_2 	= BX..'sliderThumb_press.png'
ResLib.SLIDER_MAXS 		= BX..'slider_max_value.png'
ResLib.BIG_DUI_GOU		= BX..'big_duigou.png'
ResLib.DUI_GOU  		= BX..'duigou.png'
ResLib.INSURAN_BTN   	= BX..'twrist.png'
ResLib.INSURAN_BTN_PRESS= BX..'twrist_press.png'

ResLib.OPERATION_BG 	= BX..'sliderBg.png'
ResLib.PROGRESS_BAR     = BX..'progress_bar.png'
ResLib.ICON_TAG 		= BX..'icon_tag.png'
-- ResLib.OUTS_BG 			= BX..'outs_bg.png'
ResLib.OUTS_BORDER 		= BX..'outs_border.png'
ResLib.CHIP_BG			= BX..'chip_bg.png'
-- ResLib.INSURANCE_BG     = BX..'insurance_bg.png'
-- ResLib.MARK_BG			= BX..'markbg.png'
ResLib.PLAYER_BG		= BX..'player_bg.png'
ResLib.PLAYER_BLINK 	= BX..'player_blink.png'
--mtt Reward
local ROOT_NAME = "mtt/reward/"
ResLib.CLOSE_NORMAL 		= "ui/ui_btn1_c.png"
ResLib.CLOSE_PRESS  		= "ui/ui_btn1.png"
ResLib.REWARD_BOARD		= ROOT_NAME.."reward_board.png"
ResLib.REWARD_NUMBER		= ROOT_NAME.."reward_number_1.png"
ResLib.REWARD_TEXT		= ROOT_NAME.."reward_text.png"
ResLib.REWARD_EFFECT     = ROOT_NAME.."reward_effect.png"
ResLib.REWARD_TICK       = ROOT_NAME.."reward_tick.png"


-- color
ResLib.COLOR_BLUE = cc.c3b(51, 102, 204)
ResLib.COLOR_BLUE1 = cc.c3b(168, 199, 235)
ResLib.COLOR_BLUE2 = cc.c3b(36, 77, 124)
ResLib.COLOR_BLUE3 = cc.c3b(144,162,203)
ResLib.COLOR_BLUE4 = cc.c3b(91,146,255) --多见于复选框 选中状态
ResLib.COLOR_GREEN = cc.c3b(0, 153, 51)
ResLib.COLOR_WHITE = cc.c3b(204, 204, 204)
ResLib.COLOR_YELLOW = cc.c3b(250, 252, 117)
ResLib.COLOR_GREY = cc.c3b(136, 136, 136)
ResLib.COLOR_GREY1 = cc.c3b(170, 170, 170)
ResLib.COLOR_GREY2 = cc.c3b(62, 69, 87)
ResLib.COLOR_GREY3 = cc.c3b(130, 130, 130)
ResLib.COLOR_ORANGE = cc.c3b(204, 153, 0)
ResLib.COLOR_ORANGE1 = cc.c3b(254, 108, 0)
ResLib.COLOR_PURPLE = cc.c3b(168, 119, 247)
ResLib.COLOR_BLACK = cc.c3b(1,7,21)
ResLib.COLOR_RED = display.COLOR_RED

ResLib.COLOR_YELLOW1 = cc.c3b(220, 204, 157)

function ResLib.reloadSrc()
    require 'ui.UIUtil'
end

return ResLib