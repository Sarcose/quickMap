function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function deepcopy(orig,src)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key,src)] = deepcopy(orig_value,src)
        end
        setmetatable(copy, deepcopy(getmetatable(orig),src))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function tablePrint(t, name, tab, exclude, limit)
	local stop = false
	if limit then if limit == 1 then stop = true else limit = limit - 1 end end
	name = name or "table"
	tab = tab or ""
	print(tostring(tab).."  "..tostring(name).."= {")
	for i,v in pairs(t) do
		if i ~= exclude then
			if (type(v) == "table") then
				if not stop then tablePrint(t[i], i, tostring(tab).."  ",exclude,limit) 
					else print(tostring(tab).."    "..tostring(i).."= "..tostring(v))
				end

			else
			print(tostring(tab).."    "..tostring(i).."= "..tostring(v))
			end
		end
	end
	print(tostring(tab).."    ".."}")
end

function boolSwitch(bool)
    if bool then return false else return true end
end


function TableToString(tInput, nCount)
    local sRet = "";
    
    local sTab = "";
    
    for x = 1, nCount do
    sTab = sTab.."\t";
    end
    
    local sIndexTab = sTab.."\t";
    
    nCount = nCount + 1;
    
        if type(tInput) == "table" then
        sRet = sRet.."{\r\n";
                    
            for vIndex, vItem in pairs(tInput) do
            local sIndexType = type(vIndex);
            local sItemType = type(vItem);
            local sIndex = "";
                    
                --write the index to string
                if sIndexType == "number" then
                sRet = sRet..sTab.."["..vIndex.."] = ";
                        
                elseif sIndexType == "string" then
                                
                    if string.find(vIndex, '%W', 1) then
                    sIndex = sIndexTab.."[\""..vIndex.."\"] = ";
                    else
                    sIndex = sIndexTab..vIndex.." = ";
                    end
                            
                end
                
                --write the	item to string
                if sItemType == "number" then
                sRet = sRet..sIndex..vItem..",\r\n"
                
                elseif sItemType == "string" then
                
                    for nIndex, tChar in pairs(tEscapeChars) do
                    vItem = string.gsub(vItem, tChar.Char, tChar.RelacementChar);
                    end
                
                sRet = sRet..sIndex.."\""..vItem.."\",\r\n";
                
                elseif sItemType == "boolean" then
                
                    if vItem then
                    sRet = sRet..sIndex.."true,\r\n";
                    else
                    sRet = sRet..sIndex.."false,\r\n";
                    end
                
                elseif sItemType == "nil" then
                sRet = sRet..sIndex.."nil,\r\n"
                
                elseif sItemType == "function" then
                sRet = sRet..sIndex..GetFunctionName(vItem, getfenv(vItem), "")..",\r\n";
                                        
                elseif sItemType == "userdata" then
                --do the userdata stuff here...
                
                elseif sItemType == "table" then
                sRet = sRet..sIndex..TableToString(vItem, nCount)..",\r\n";			
                
                end
                
            end
                
        end
    
    sRet = sRet..sTab.."}"
    
    return sRet
    end