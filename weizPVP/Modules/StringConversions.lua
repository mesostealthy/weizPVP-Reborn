---------------------------------------------------------------------------------------------------
-- |> STRING CONVERSIONS
-- : Converts font string characters to allow for more regional support
--: Contains UTF8 functions for BCC
--: Cyrillic ↔️ Romanian (~Russian ↔️ ~Latin font characters)
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local gsub = gsub
local type = type
local strbyte = strbyte
local strlenutf8 = strlenutf8
local string_upper = string.upper
local error = error
local strlen = strlen
local strsub = strsub

--: Cyrillic To Romanian LUT :---------
-- Source: https://en.wikipedia.org/wiki/Romanization_of_Russian
-- Method: Passport (2013) ICAO transliteration
local LUT_CyrillicToRomanian = {
  ["А"] = "a",
  ["а"] = "a",
  ["Б"] = "b",
  ["б"] = "b",
  ["В"] = "v",
  ["в"] = "v",
  ["Г"] = "g",
  ["г"] = "g",
  ["Д"] = "d",
  ["д"] = "d",
  ["Е"] = "e",
  ["е"] = "e",
  ["Ё"] = "e",
  ["ё"] = "e",
  ["Ж"] = "zh",
  ["ж"] = "zh",
  ["З"] = "z",
  ["з"] = "z",
  ["И"] = "i",
  ["и"] = "i",
  ["Й"] = "i",
  ["й"] = "i",
  ["К"] = "k",
  ["к"] = "k",
  ["Л"] = "l",
  ["л"] = "l",
  ["М"] = "m",
  ["м"] = "m",
  ["Н"] = "n",
  ["н"] = "n",
  ["О"] = "o",
  ["о"] = "o",
  ["П"] = "p",
  ["п"] = "p",
  ["Р"] = "r",
  ["р"] = "r",
  ["С"] = "s",
  ["с"] = "s",
  ["Т"] = "t",
  ["т"] = "t",
  ["У"] = "u",
  ["у"] = "u",
  ["Ф"] = "f",
  ["ф"] = "f",
  ["Х"] = "kh",
  ["х"] = "kh",
  ["Ц"] = "ts",
  ["ц"] = "ts",
  ["Ч"] = "ch",
  ["ч"] = "ch",
  ["Ш"] = "sh",
  ["ш"] = "sh",
  ["Щ"] = "shch",
  ["щ"] = "shch",
  ["Ъ"] = "ie",
  ["ъ"] = "ie",
  ["Ы"] = "y",
  ["ы"] = "y",
  ["Ь"] = "",
  ["ь"] = "",
  ["Э"] = "e",
  ["э"] = "e",
  ["Ю"] = "iu",
  ["ю"] = "iu",
  ["Я"] = "ia",
  ["я"] = "ia"
}

---------------------------------------------------------------------------------------------------
--|> UTF8 FUNCTIONS <|----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--> UTF8 CHAR BYTES <------------------------------------------------
local function utf8charbytes(s, i)
    -- argument defaults
    i = i or 1

    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8charbytes' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8charbytes' (number expected, got " .. type(i) .. ")")
    end

    local c = strbyte(s, i)

    -- determine bytes needed for character, based on RFC 3629
    -- validate byte 1
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1
    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = strbyte(s, i + 1)

        if not c2 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        return 2
    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = strbyte(s, i + 1)
        local c3 = strbyte(s, i + 2)

        if not c2 or not c3 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 224 and (c2 < 160 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 237 and (c2 < 128 or c2 > 159) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        return 3
    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = strbyte(s, i + 1)
        local c3 = strbyte(s, i + 2)
        local c4 = strbyte(s, i + 3)

        if not c2 or not c3 or not c4 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 240 and (c2 < 144 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 244 and (c2 < 128 or c2 > 143) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 4
        if c4 < 128 or c4 > 191 then
            error("Invalid UTF-8 character")
        end

        return 4
    else
        error("Invalid UTF-8 character")
    end
end

--> UTF8 SUB <-------------------------------------------------------
local function utf8sub(s, i, j)
    -- argument defaults
    j = j or -1

    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8sub' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8sub' (number expected, got " .. type(i) .. ")")
    end
    if type(j) ~= "number" then
        error("bad argument #3 to 'utf8sub' (number expected, got " .. type(j) .. ")")
    end

    local pos = 1
    local bytes = strlen(s)
    local len = 0

    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or strlenutf8(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1

    -- can't have start before end!
    if startChar > endChar then
        return ""
    end

    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes

    while pos <= bytes do
        len = len + 1

        if len == startChar then
            startByte = pos
        end

        pos = pos + utf8charbytes(s, pos)

        if len == endChar then
            endByte = pos - 1
            break
        end
    end

    return strsub(s, startByte, endByte)
end

--> Format Character Name <------------------------------------------
function NS.ConvertString_CyrillicToRomanian(charName)
    if charName == nil then
        return
    end
    charName = gsub(charName, "-(.*)", "")
    local formattedCharName
    local c

    -- transliterate character by character
    for i = 1, strlenutf8(charName) do
        -- Get utf8 sub
        c = utf8sub(charName, i, i)
        c = LUT_CyrillicToRomanian[c] or c

        -- Uppercase for first character
        if i == 1 then
            formattedCharName = string_upper(c) --uppercase the first character
        else
            formattedCharName = formattedCharName .. c
        end
    end

    -- return formatted name
    return formattedCharName
end
