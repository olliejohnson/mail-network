require("cryptoNet")

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

function writeCardID(id)
    local f_card_data = fs.open("disk/card_data", "w+")
    f_card_data.write(id)
end

function writeCardName(username)
    disk.setLabel(username.."'s card")
end

function onStart()
    socket = connect("central.netfs")
    login(socket, "termpoint", "secureaccess")
end

function onEvent(event)
    local msgType = event[1]

    if msgType == "login" then
        local username = event[2]
        local socket = event[3]
        print("Logged in as "..username)
        send(socket, "login_req")
    elseif msgType == "login_failed" then
        print("Unknown login.")
    elseif msgType == "logout" then
        print("Door closed.")
        local socket = event[3]
        enterDetails(socket)
    elseif msgType == "encrypted_message" then
        message = event[2]
        socket = event[3]
        if message == "accept_" then
            term.clear()
            write("Enter Username: ")
            local username = read()
            writeCardName(username)
            send(socket, "add_card:"..username)
        elseif split(message, ":")[1] == "card_id" then
            writeCardID(split(message, ":")[2])
            send(socket, "chk")
        end
    end
end

function main()
    startEventLoop(onStart, onEvent)
end

pcall(main)