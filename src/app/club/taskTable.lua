local taskTable = {

	{	
		taskId = 1,
		level = "一",						-- 当前等级
		person_total = 40,					-- 当前俱乐部人数上限
		scoreboard_total = 12000000,		-- 达到记分牌总数
		scoreboard_award = 12000,			-- 可获得记分牌奖励
		nextLevel = "二",					-- 下一等级
		nextPerson_total = 80,				-- 下一等级俱乐部人数上限
	},
	{
		taskId = 2,
		level = "二",
		person_total = 80,
		scoreboard_total = 24000000,
		scoreboard_award = 48000,
		nextLevel = "三",
		nextPerson_total = 120,
	},
	{
		taskId = 3,
		level = "三",
		person_total = 120,
		scoreboard_total = 36000000,
		scoreboard_award = 72000,
		nextLevel = "四",
		nextPerson_total = 180,
	},
	{
		taskId = 4,
		level = "四",
		person_total = 180,
		scoreboard_total = 54000000,
		scoreboard_award = 162000,
		nextLevel = "五",
		nextPerson_total = 260,
	},
	{
		taskId = 5,
		level = "五",
		person_total = 260,
		scoreboard_total = 78000000,
		scoreboard_award = 312000,
		nextLevel = "六",
		nextPerson_total = 360,
	},
	{
		taskId = 6,
		level = "六",
		person_total = 360,
		scoreboard_total = 108000000,
		scoreboard_award = 540000,
		nextLevel = "七",
		nextPerson_total = 480,
	},
	{
		taskId = 7,
		level = "七",
		person_total = 480,
		scoreboard_total = 144000000,
		scoreboard_award = 864000,
		nextLevel = "八",
		nextPerson_total = 520,
	},
	{
		taskId = 8,
		level = "八",
		person_total = 520,
		scoreboard_total = 156000000,
		scoreboard_award = 1092000,
		nextLevel = "九",
		nextPerson_total = 680,
	},
	{
		taskId = 9,
		level = "九",
		person_total = 680,
		scoreboard_total = 204000000,
		scoreboard_award = 1632000,
		nextLevel = "十",
		nextPerson_total = 1000,
	},
	{
		taskId = 10,
		level = "十",
		person_total = 1000,
		scoreboard_total = 300000000,
		scoreboard_award = 3000000,
		nextLevel = 0,
		nextPerson_total = 0,
	}
}

return taskTable