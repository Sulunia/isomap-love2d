--miscUtils library
--Implements math, string and misc functions for usage with other modules

function lerp(a, b, rate) --EMPLOYEE OF THE MONTH
	local result = (1-rate)*a + rate*b
	return result
end

function round(num, precision)
	return tonumber(string.format("%." .. (precision or 0) .. "f", num))
end

function clamp(number, maxvalue, minvalue)
	if number > maxvalue then
		number = maxvalue
	elseif number < minvalue then
		number = minvalue
	end
	return number
end

function string:split(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField, nStart = 1, 1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	return aRecord
--Credit goes to JoanOrdinas @ lua-users.org
end


function getFileExtension(path)
  return path:match("^.+(%..+)$")
end
