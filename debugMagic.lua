---@diagnostic disable: lowercase-global
--debugMagic.lua

if preG == nil then
    preG = {}
    for k, _ in pairs(_G) do
        preG[k] = true
    end
else
    local getStacktrace = function(stacktrace, pCallFunctionName, pCallParameters, pCallResult)
        local extractFunctionPosition = function(line)
            line = line:match '^%s*(.*%S)' or '' -- trim
            local s, e = line:find('..."]:')
            local remainingLine = line:sub(e + 1)
            local rs, re = remainingLine:find(':')
            return {
                fileName = "(file starting with '" .. line:sub(10, s - 1) .. "')",
                lineNo   = remainingLine:sub(1, re - 1),
            }
        end

        local stacktraceTable = {}
        local lineIdx = 1
        local position = nil
        for line in stacktrace:gmatch("[^\r\n]+") do
            if lineIdx > 2 then
                local lineType = lineIdx % 3
                if lineType == 0 then
                    local _, pos = line:find("function '")
                    if pos then
                        functionName = line:sub(pos + 1, -2)
                        if position then
                            parameter = ''
                        else
                            position = extractFunctionPosition(pCallResult)
                            parameter = pCallParameters
                        end
                        table.insert(stacktraceTable,
                            { functionName = functionName, fileName = position.fileName, lineNo = position.lineNo,
                                parameter = parameter })
                    end
                end
                if lineType == 1 then
                    position = extractFunctionPosition(line)
                end
            end

            lineIdx = lineIdx + 1
        end

        if position then
            parameter    = ''
            functionName = nil
        else
            position     = extractFunctionPosition(pCallResult)
            parameter    = pCallParameters
            functionName = pCallFunctionName
        end
        table.insert(stacktraceTable,
            { functionName = functionName, fileName = position.fileName, lineNo = position.lineNo, parameter = parameter })

        return stacktraceTable
    end

    local extractParameters = function(...)
        local params = nil
        for i, p in ipairs({ ... }) do
            params = (params and params .. ', ' or '') .. tostring(p)
        end
        return params
    end

    for functionName, func in pairs(_G) do
        if not preG[functionName] and type(_G[functionName]) == 'function' then
            _G[functionName] = function(...)
                local ok, result = pcall(func, ...)
                if ok then
                    return result
                else
                    local stacktraceString = debug.traceback("Stack trace")
                    local o, r = pcall(function(result, functionName, ...)
                        local s, e = result:find('..."]:[0-9]+: ')
                        local errorLine = 'Error: ' .. result:sub(e + 1) .. ' - stack trace:'
                        local stacktrace = getStacktrace(stacktraceString, functionName, extractParameters(...), result)
                        for _, d in ipairs(stacktrace) do
                            errorLine = errorLine ..
                            "\r\n  at " ..
                            d.fileName ..
                            ':' ..
                            d.lineNo .. (d.functionName and ':' .. d.functionName .. '(' .. (d.parameter or '') .. ')' or '')
                        end
                        Log(errorLine)
                    end, result, functionName, ...)

                    return nil
                end
            end
        end
    end
end
