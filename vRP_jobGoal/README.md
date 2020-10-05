# vRP_jobGoal

**Job Goal a.k.a Money Goal**

* A little description of this:
When a player works on a job and he is paid with any amount of money the Goal is growing up. When the goal is reached all players online at that moment on server get's an random amount of money and a little animation with **Job Goal Passed Respect+** like Mission passed from GTA:SA

* How to make this thing work?

* **STEP 1:**
You'll have to add this line of code on ```vRP/base.lua``` under the ```Tunnel.getInterface("vRP","vRP")``` function
--> Line of code: **```jobGoal = Proxy.getInterface("vRP_jobGoal")```**

* **STEP 2:**
After this you'll have to go in vRP/modules/money.lua and replace your **```vRP.giveMoney(user_id,amount)```** function with this one:

```lua
function vRP.giveMoney(user_id,amount,jobs)
  local money = vRP.getMoney(user_id)
  vRP.setMoney(user_id,money+amount)
  if(jobs == "true")then
    jobGoal.cresteJobGoal({tonumber(amount)})
  end
end
```

* **STEP 3:**
Go into your all jobs in **```server.lua```** and add ***,true*** like this https://i.imgur.com/oGqW33O.png

I hope you enjoy using this <3
Much love from machiamavlad also known as sefu ma-tii
