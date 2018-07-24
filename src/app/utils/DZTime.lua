local DZTime = {}


function DZTime.secondsConvertToTime(seconds)
	if seconds < 0 then
		seconds = 0
	end
	local dayUnit,hourUnit,minuteUnit = 86400,3600,60
	local dayValue,hourValue,minuteValue,secondValue = 0,0,0

	dayValue = math.floor( seconds / dayUnit )
	hourValue = math.floor( (seconds - dayValue * dayUnit ) / hourUnit )
	minuteValue = math.floor( ( seconds - hourValue * hourUnit - dayValue * dayUnit ) / minuteUnit )
	secondValue = seconds % 60

	local rtab = {}
	rtab['day'] = dayValue
	rtab['hour'] = hourValue
	rtab['minute'] = minuteValue
	rtab['seconds'] = secondValue
	return rtab
end

function DZTime.secondsHourFormat(seconds)
	if seconds <= 0 then return '00:00:00' end
	
	local hms = DZTime.secondsConvertToTime(seconds)
	local thour = hms['hour']
	local tmin = hms['minute']
	local tsec = hms['seconds']
	if thour < 10 then
		thour = '0'..thour 
	end
	if tmin < 10 then
		tmin = '0'..tmin 
	end
	if tsec < 10 then
		tsec = '0'..tsec 
	end
	return thour..':'..tmin..':'..tsec
end

function DZTime.minsHourFormat(seconds)
	if seconds <= 0 then return '00:00' end
	
	local hms = DZTime.secondsConvertToTime(seconds)
	local thour = hms['hour']
	local tmin = hms['minute']
	if thour < 10 then
		thour = '0'..thour 
	end
	if tmin < 10 then
		tmin = '0'..tmin 
	end

	return thour..':'..tmin
end

function DZTime.secondsMinFormat(seconds)
	if seconds <= 0 then return '00:00' end
	
	local hms = DZTime.secondsConvertToTime(seconds)
	local tmin = hms['minute']
	local tsec = hms['seconds']
	if tmin < 10 then
		tmin = '0'..tmin 
	end
	if tsec < 10 then
		tsec = '0'..tsec 
	end
	return tmin..':'..tsec
end

function DZTime.getSystemTime()
	return os.date("*t", os.time())
end

function DZTime.secondsToMinText(seconds)
	local int,_ = math.modf(seconds / 60)
	local float = math.mod(seconds, 60)
	if float == 0 then
		return int..'分钟'
	end
	if int == 0 then
		return float..'秒'
	end
	return int..'分钟'..float..'秒'
end

return DZTime