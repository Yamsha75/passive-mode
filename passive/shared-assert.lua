function assertArgumentIsElement(variable, argumentNumber)
    if isElement(variable) then return true end

    local variableType = getVariableType(variable)

    if argumentNumber then
        error(
            string.format(
                "expected element at argument %d, got %s", argumentNumber, variableType
            ), 2
        )
    else
        error(string.format("expected element as argument, got %s", variableType), 2)
    end
end

function assertArgumentType(variable, expectedType, argumentNumber)
    local variableType = getVariableType(variable)
    if variableType == expectedType then return true end

    if argumentNumber then
        error(
            string.format(
                "expected %s at argument %d, got %s", expectedType, argumentNumber,
                    variableType
            ), 2
        )
    else
        error(
            string.format(
                "expected %s as argument, got %s", expectedType, variableType
            ), 2
        )
    end
end

function assertSourceType(variable, expectedType)
    local variableType = getVariableType(variable)
    if variableType == expectedType then return true end

    error(
        string.format(
            "expected %s as event source, got %s", expectedType, variableType
        ), 2
    )
end
