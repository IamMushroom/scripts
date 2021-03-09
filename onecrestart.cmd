SET SRV="1C:Enterprise 8.3 Server Agent"
SET PATH="C:\Program Files (x86)\1cv8\srvinfo\reg_1541"

net stop %SRV%
timeout 120
cd %PATH%
for /d %%i in (%PATH%\*) do (
  rd /s/q "%%i"
)
timeout 120
net start %SRV%