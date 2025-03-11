-- // SERVICES // --

-- // MODULES // --

local parser = {}

-- // VARIABLES // --

-- // FUNCTIONS // --

function parser.ParseTTML(data, displayType) -- Data = TTML, displayType = 2 (sentance by sentance) or 3 (syllable)
	local result = {
		["Lenght"] = 0,
		["Synced-Lyrics"] = {}
	}
	
	-- Prep Song
	local BodyS = parser.getBodyString(data)
	local songDuration = parser.grabSongDur(data)
	local cleanUpStart = parser.cleanUpStart(BodyS)
	
	result["Lenght"] = songDuration
	
	-- Split down to lines
	local seperatedLines
	if displayType == 2 then
		
		local songSections = parser.splitSongParts(cleanUpStart)
		seperatedLines = parser.extractLineData(data)
		
		for _, line in seperatedLines do
			local lineFinal = {}
			local splitLine = string.split(line.Text, " ")
			local start = line.Start
			local e = line.Start
			
			for _, text in splitLine do
				table.insert(lineFinal, {Text = text, Start = start, End = e})
			end

			table.insert(result["Synced-Lyrics"], lineFinal)

		end
		
	else
		
		local songSections = parser.splitSongParts(cleanUpStart)
		seperatedLines = parser.splitLines(songSections)
		
		for _, line in seperatedLines do

			table.insert(result["Synced-Lyrics"], parser.extractLyricData(line))

		end
		
	end
	
	return result
	
end

function parser.getBodyString(data)
	return data:match('<body(.*)</body>')
end

function parser.grabSongDur(data)
	local baseTime = data:match('dur="(.-)"')
	
	return parser.convertToMS(baseTime)
end

function parser.convertToMS(baseTime)
	
	local minutes, seconds, milliseconds = baseTime:match("(%d+):(%d+)%.(%d+)")

	minutes = tonumber(minutes) or 0
	seconds = tonumber(seconds) or 0
	milliseconds = tonumber(milliseconds) or 0
	
	return (minutes * 60 * 1000) + (seconds * 1000) + milliseconds
	
end

function parser.splitSongParts(data)
	local result = {}
	
	for text in data:gmatch('<div.-">(.-)</div>') do
		table.insert(result, text)
	end
	
	return result
	
end

function parser.cleanUpStart(data)
	return data:match(">(.*)")
end

function parser.checkForSeconds(timeStr)
	if not string.find(timeStr, ":") then
		timeStr = "0:"..timeStr
	end
	return timeStr
end

function parser.extractLyricData(line)
	
	local lineTextData = {}
	
	for begin, ending, lyric in line:gmatch('<span begin="([^"]+)" end="([^"]+)">(.-)</span>') do
		
		table.insert(lineTextData, {Start = parser.convertToMS(parser.checkForSeconds(begin)), End = parser.convertToMS(parser.checkForSeconds(ending)), Text = lyric})
	end
	
	return lineTextData
	
end

function parser.extractLineData(line)

	local lineTextData = {}

	for begin, ending, lyric in line:gmatch('<p begin="([^"]+)" end="([^"]+)">(.-)</p>') do

		table.insert(lineTextData, {Start = parser.convertToMS(parser.checkForSeconds(begin)), End = parser.convertToMS(parser.checkForSeconds(ending)), Text = lyric})
	end

	return lineTextData

end

function parser.splitLines(data)

	local lines = {}

	for _, line in data do
		
		for text in line:gmatch('<p.-">(.-)</p>') do
			table.insert(lines, text)
		end
		
	end
	
	return lines

end

-- // SCRIPT // --

-- // MODULE RETURN // --

return parser