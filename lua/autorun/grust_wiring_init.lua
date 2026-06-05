IO = IO or {}
local function add_filessh(dir)
    local files, folders = file.Find(dir .. "*", "LUA")
    for key, file_name in pairs(files) do
        if SERVER then AddCSLuaFile(dir .. file_name) end
        include(dir .. file_name)
        print("[R-Wiring] Shared: " .. dir .. file_name)
    end

    for key, folder_name in pairs(folders) do
        add_filessh(dir .. folder_name .. "/")
    end
end

add_filessh("r_wiring/core/setable/")
add_filessh("r_wiring/core/shared/")
local function add_filessv(dir)
    local files, folders = file.Find(dir .. "*", "LUA")
    for key, file_name in pairs(files) do
        if SERVER then
            include(dir .. file_name)
            print("[R-Wiring] Server: " .. dir .. file_name)
        end
    end

    for key, folder_name in pairs(folders) do
        add_filessv(dir .. folder_name .. "/")
    end
end

add_filessv("r_wiring/core/server/")
local function add_files(dir)
    local files, folders = file.Find(dir .. "*", "LUA")
    for key, file_name in pairs(files) do
        if SERVER then AddCSLuaFile(dir .. file_name) end
        if CLIENT then include(dir .. file_name) end
        print("[R-Wiring] Client: " .. dir .. file_name)
    end

    for key, folder_name in pairs(folders) do
        add_files(dir .. folder_name .. "/")
    end
end

add_files("r_wiring/core/client/")