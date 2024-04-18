urls = {
    {"client.lua", "https://raw.githubusercontent.com/olliejohnson/mail-network/main/client/client.lua"},
    {"cryptoNet.lua", "https://raw.githubusercontent.com/olliejohnson/mail-network/main/server/cryptoNet.lua"}
}

files = {
    "config.tbl"
}

function download(name, url)
    request = http.get(url)
    data = request.readAll()

    if fs.exists(name) then
        fs.delete(name)
        file = fs.open(name, "w")
        file.write(data)
        file.close()
    else
        file = fs.open(name, "w")
        file.write(data)
        file.close()
    end
end

function wget_run(url, arg)
    shell.run("wget", "run", url, arg)
end

function file_create(name)
    if fs.exists(name) then
        return
    else
        file = fs.open(name, "w")
        file.write("")
        file.close()
    end
end

function writeHostname()
    config = {}
    write("Enter Hostname: ")
    local hostname = read()
    config.hostname = hostname
    file = fs.open("config.tbl", "w")
    file.write(textutils.serialise(config))
    file.close()
end

for k, v in ipairs(urls) do
    download(unpack(v))
end

for k, v in ipairs(files) do
    file_create(v)
end

writeHostname()
wget_run("https://basalt.madefor.cc/install.lua", "release")