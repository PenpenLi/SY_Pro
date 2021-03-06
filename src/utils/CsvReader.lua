-- 去掉字符串左空白
local function trim_left(s)
	return string.gsub(s, "^%s+", "");
end


-- 去掉字符串右空白
local function trim_right(s)
	return string.gsub(s, "%s+$", "");
end


-- 解析一行
local function parseline(line)
	local ret = {};
	local s = line .. ",";  -- 添加逗号,保证能得到最后一个字段
	
	while (s ~= "") do
		local v = "";
		local tl = true;
		local tr = true;

		while(s ~= "" and string.find(s, "^,") == nil) do
			-- print(111,s);
			-- print(">>> " .. tostring( string.find(s, "\n") ));
			if(string.find(s, "^\"")) then
				local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");
				--print(2,vx,vz);
				if(vx == nil) then
					return nil;  -- 不完整的一行
				end

				-- 引号开头的不去空白
				if(v == "") then
					tl = false;
				end

				v = v..vx;
				s = vz;

				--print(3,v,s);

				while(string.find(s, "^\"")) do
					local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");
					--print(4,vx,vz);
					if(vx == nil) then
						return nil;
					end

					v = v.."\""..vx;
					s = vz;
					--print(5,v,s);
				end

				tr = true;
			else
				local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");
				--print(6,vx,vz);
				if(vx~=nil) then
					v = v..vx;
					s = vz;
				else
					v = v..s;
					s = "";
				end
				--print(7,v,s);

				tr = false;
			end
		end
		-- print(7,"ret["..table.getn(ret).."]=".."\""..v.."\"");

		if(tl) then v = trim_left(v); end
		if(tr) then v = trim_right(v); end

		ret[table.getn(ret)+1] = v;
		-- print(8,"ret["..table.getn(ret).."]=".."\""..v.."\"");

		if(string.find(s, "^,")) then
			s = string.gsub(s,"^,", "");
		end

	end

	return ret;
end



--解析csv文件的每一行
local function getRowContent(file)
	local content = nil;

	local check = false
	local count = 0
	while true do
		local t = file:read()
		-- print("tttt " .. tostring(t) .. tostring(string.find(t, '\n')) );
		if not t then  
			if count==0 then 
				check = true 
			end  
			break 
		end

		if not content then
			content = t
		-- else
		-- 	content = content..t
			
		end

		local i = 1
		while true do
			local index = string.find(t, "\"", i)
			if not index then 
				break 
			end
			i = index + 1
			count = count + 1
		end

		if count % 2 == 0 then 
			check = true 
			break 
		end
	end

	if not check then  
		assert(1~=1) 
	end

	return content
end



--解析csv文件
local function LoadCsv(fileName)
	local ret = {};

	local file = io.open(fileName, "r")
	assert(file)
	local content = {}
	while true do
		local line = getRowContent(file)
		if not line then break end
		table.insert(content, line)
	end

	for k,v in pairs(content) do
		ret[#ret+1] = parseline(v);
	end

	file:close()

	return ret
end

function getCsvDictionary( fileName )
	local t = LoadCsv( cc.FileUtils:getInstance():fullPathForFilename(fileName) )
	local data = {};
	local keys = {};
	for k,v in pairs(t) do
	    for i,j in pairs(v) do
	    	-- 将第一行的备注用作key
	        if k == 1 then
	            keys[ i ] = j;
	        else
	        	if data[ k-1 ] == nil then
	        		data[ k-1 ] = {};
	        	end
	            data[ k-1 ][ keys[i] ] = j;
	        end
	    end
	end
	return data;
end













