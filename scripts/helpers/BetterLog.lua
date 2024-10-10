--BetterLog.lua
--- forts script API ---
--use BetterLog for improved log function (convert to string and log tables)
----------------------------------------------------------------------------------------------------------------
--Improved Log functions----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--Function LogTables
--Log the given table in game format
--Table : table to log
--IndentLevel : indentation level of the table content (ex : 1 if it's the first time the function is called)

function LogTables(Table, IndentLevel)
    if Table == nil then
        Log("nil")
    else
        IndentLevel = IndentLevel or 1
        local indent = string.rep("    ", IndentLevel)
        local indentinf = string.rep("    ", IndentLevel-1)
        local metatable = getmetatable(Table)
        if metatable and metatable.__tostring then
            Log(indent .. tostring(Table) .. ",")
        else
            Log(indentinf .. "{")
            for k, v in pairs(Table) do
                if type(k) == "number" then
                    if type(v) == "table" then
                        Log(indent .. "[" .. tostring(k) .. "] = ")
                        LogTables(v, IndentLevel + 1)
                    elseif type(v) == "function" then
                        LogFunction(v)
                    elseif type(v) == "string" then
                        Log(indent .. "[" .. tostring(k) .. '] = "' .. v .. '",')
                    else
                        Log(indent .. "[" .. tostring(k) .. "] = " .. tostring(v) .. ",")
                    end
                else
                    if type(v) == "table" then
                        Log(indent .. tostring(k) .. " = ")
                        LogTables(v, IndentLevel + 1)
                    elseif type(v) == "function" then
                        LogFunction(v)
                    elseif type(v) == "string" then
                        Log(indent .. tostring(k) .. ' = "' .. v .. '",')
                    else
                        Log(indent .. tostring(k) .. " = " .. tostring(v) .. ",")
                    end
                end
            end
            if IndentLevel > 1 then
                Log(indentinf .. "},")
            else
                Log(indentinf .. "}")
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------------
--Function LogFunction
--If FindFunctionName is present, logs the name of the function (instead of the memory adress)

function LogFunction(Func)
    if FindFunctionName and FindFunctionName(Func) then
        Log("function : " .. FindFunctionName(Func))
    else
        Log(tostring(Func))
    end
end

----------------------------------------------------------------------------------------------------------------
--Function BetterLog
--Log the argument in the approriate format. convert it automatically to a string if needed.
--v : variable to log (any type)

function BetterLog(v)
    if type(v) == "table" then
        local metatable = getmetatable(v) --metatables are a lua feature to modify how table behave (mainly operators). Vec3 has one allowing you to use + and * on them like a mathematical vector
        if metatable and metatable.__tostring then --if the table has a built in print method, use it
            Log(tostring(v))
        else
            LogTables(v) --otherwise use the default method of tables
        end
    elseif type(v) == "function" then
        LogFunction(v)
    else
        Log(tostring(v))
    end
end

function ShallowLogTable(t)
    if type(t) == "table" then
        Log("{")
        for k, v in pairs(t) do
            if type(v) == "table" then
                Log("\t" .. tostring(k) .. " = table,")
            else
                Log("\t" .. tostring(k) .. " = " .. tostring(v) .. ",")
            end
        end
        Log("}")
    else
        BetterLog(t)
    end

end