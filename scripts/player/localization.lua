

function LocalizeStrings()
    local language = Language()

    if language == "English" then
        CurrentLanguage = LocalEnglish
    elseif language == "Chinese" then
        CurrentLanguage = LocalChinese
    else
        CurrentLanguage = LocalEnglish
    end
end