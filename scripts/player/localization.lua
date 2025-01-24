

function LocalizeStrings()
    local language = Language()


    CurrentLanguage = _G["Local" .. language]
    if not CurrentLanguage then
        CurrentLanguage = LocalEnglish
    end
end