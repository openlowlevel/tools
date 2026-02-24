#!/usr/bin/env lua


local keyword = arg[1]
if not keyword then
    error("usage: lua tool.lua <keyword>")
end

-- ANSI color
local COLOR = {
    RESET = "\27[0m",
    RED   = "\27[31m",
    GREEN = "\27[32m",
    GRAY  = "\27[90m",
}

-- 画像・バイナリっぽい拡張子
local ignore_ext = {
    png = true,
    jpg = true,
    jpeg = true,
    gif = true,
    bmp = true,
    webp = true,
    exe = true,
    dll = true,
    so = true,
    zip = true,
    tar = true,
    gz = true,
    pdf = true,
}

local function is_binary(path)
    local ext = path:match("%.([%w]+)$")
    return ext and ignore_ext[ext:lower()]
end

local function scan(dir)
    for entry in io.popen('ls -p "' .. dir .. '"'):lines() do
        local path = dir .. "/" .. entry

        -- ディレクトリ
        if entry:sub(-1) == "/" then
            scan(path:sub(1, -2)) -- 最後の / を除く
        else
            if is_binary(entry) then
                print(COLOR.GRAY .. "PASS  " .. path .. COLOR.RESET)
            else
                local f = io.open(path, "r")
                if f then
                    local text = f:read("*a")
                    f:close()

                    if text:find(keyword, 1, true) then
                        print(COLOR.GREEN .. "MATCH " .. path .. COLOR.RESET)
                    else
                        print(COLOR.RED .. "NOPE  " .. path .. COLOR.RESET)
                    end
                else
                    print(COLOR.GRAY .. "SKIP  " .. path .. COLOR.RESET)
                end
            end
        end
    end
end

local pwd = io.popen("pwd"):read("*l")
print("TOOL | Workdir:", pwd)
print("TOOL | Search :", keyword)
print("--------------------------------------------------")

scan(pwd)
