require("cryptoNet")

card_table = {}
dns_table = {}

function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function save(table,name)
    local file = fs.open(name,"w")
    file.write(textutils.serialize(table))
    file.close()
end
     
function load(name)
    local file = fs.open(name,"r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

function getId(username)
    for k, v in pairs(card_table) do
        if v.username == username then
            return k
        end
    end
end
    

function loadTables()
    card_table = load("card.tbl")
end

function saveTables()
    save(card_table, "card.tbl")
    save(dns_table, "logs.tbl")
end

function uuid()
    local random = math.random
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local id = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
    return id
end

function onEvent(event)
    if event[1] == "login" then
        local username = event[2]
        local socket = event[3]
        print (socket.username.." just logged in.")
    elseif event[1] == "encrypted_message" then
        local socket = event[3]
        local message = event[2]
        if split(message, ":")[1] == "card_id" then
            local id = split(message, ":")[2]
            local card_data = card_table[id]
            if card_data ~= nil then
                send(socket, "card_data:"..textutils.serialize(card_data))
            end
        elseif message == "save_tbl" then
            saveTables()
        elseif message == "load_tbl" then
            loadTables()
        elseif message == "clr_tbl" then
            card_table = {}
            dns_table = {}
            saveTables()
        elseif split(message, ":")[1] == "add_card" then
            local m_split = split(message, ":")
            local id = uuid()
            local username = m_split[2]
            data = {
                username = username,
                balance = 0
            }
            card_table[id] = data
            send(socket, "card_id:"..id)
        elseif split(message, ":")[1] == "add_dns" then
            local name = split(message, ":")[2]
            dns_table[name] = socket
        elseif split(message, ":")[1] == "send_mail" then
            local name = split(message, ":")[2]
            local sender = split(message, ":")[4]
            local id = split(message, ":")[3]
            print(message)
            local pos = split(message, ":")[5]
            print("Recived loc: "..pos)
            print(sender.." -> "..name)
            print(id)
            send(dns_table[name], "req_location:"..sender..":"..pos)
            send(dns_table[name], "recv_mail:"..id..":"..sender)
        elseif split(message, ":")[1] == "add_bal" then
            local id = split(message, ":")[2]
            local change = split(message, ":")[3]
            if tonumber(change) >= 0 then
                card_table[id].balance = card_table[id].balance + tonumber(change)
            end
        elseif split(message, ":")[1] == "rm_bal" then
            local id = split(message, ":")[2]
            local change = split(message, ":")[3]
            if card_table[id].balance >= tonumber(change) and tonumber(change) >= 0 then
                card_table[id].balance = card_table[id].balance - tonumber(change)
            end
        elseif split(message, ":")[1] == "transfer" then
            local id = split(message, ":")[2]
            local username = split(message, ":")[3]
            local change = split(message, ":")[4]
            if card_table[id].balance >= tonumber(change) and tonumber(change) >= 0 then
                if getId(username) ~= nil then
                    card_table[id].balance = card_table[id].balance - tonumber(change)
                    card_table[getId(username)].balance = card_table[getId(username)].balance + tonumber(change)
                end
            end
        elseif split(message, ":")[1] == "resp_location" then
            local origin_pos = split(message, ":")[2]
            local remote_pos = split(message, ":")[3]
            local sender = split(message, ":")[4]
            print("Recived: "..origin_pos.." and "..remote_pos)
            local x1 = split(origin_pos, ",")[1]
            local y1 = split(origin_pos, ",")[2]
            local z1 = split(origin_pos, ",")[3]
            local x2 = split(remote_pos, ",")[1]
            local y2 = split(remote_pos, ",")[2]
            local z2 = split(remote_pos, ",")[3]
            local distance = math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
            print("Distance: "..distance)
            local b_mul = math.floor(distance/100)
            local cost = 2^b_mul
            print("Cost: "..cost)
            send(dns_table[sender], "charge_bal:"..cost)
        else
            if socket.username ~= nil then
                send(socket, "accept_")
            else
                send(socket, "deny_")
            end
        end
    elseif event[1] == "connection_closed" then
        for k, v in pairs(dns_table) do
            if v == event[2] then
                dns_table[k] = nil
            end
        end
    end
end

function onStart()
    host("central.netfs", false)
end

local function main()
    loadTables()
    startEventLoop(onStart, onEvent)
    print("Saving Tables...")
    saveTables()
    print("Saved Tables.")
end

pcall(main)