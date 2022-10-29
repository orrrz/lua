	-------------------------------------------------------------------------------------------
	--开始！！！！！！！！！！！！！！！！！！
	-- LuaTools需要PROJECT和VERSION这两个信息
	PROJECT = "einkdemo"
	VERSION = "1.0.0"

	-- sys库是标配
	_G.sys = require("sys")


	gpio.setup(7, function()  end, gpio.PULLUP,gpio.RISING)
	gpio.setup(4, function()  end, gpio.PULLUP,gpio.RISING)
	gpio.setup(1, function()  end, gpio.PULLUP,gpio.RISING)
	gpio.set(7,1)
	gpio.set(4,1) --进入
	gpio.set(1,1)


	log.info("sdio", "call sdio.init")
	sdio.init(0)
	log.info("sdio", "call sdio.sd_mount")
	sdio.sd_mount(0, "/sd")
	flag = 0
    cc = 0 --文件标号
    nn = 0 --文件数量
    mubiaoshu = 0
    t = {}
	x = 0
	n = 0 --页数
	bookmark = 0
	bookmark0 = 0
	goback = 0
	backflag = 0
    wenjianmingweizhi = 30
    shubiao = 23 --光标位置
	shuaxinflag = 0
	if fdb.kvdb_init("env", "onchip_fdb") then
		log.info("fdb", "kv数据库初始化成功")
	end

	eink.model(eink.MODEL_1in54)
	eink.setup(0, 0,pin.PB00,pin.PB03,pin.PB01,pin.PB04)
	eink.setWin(200, 200, 0)--设置窗口大小
	log.info("eink", "end setup")
	log.info("e-paper 1.54", "Testing Go")
	eink.clear()--清屏
	eink.setFont(fonts.get("oppo_light_12")) 
	eink.show()

sys.taskInit(function()
while 1 do
		
	eink.model(eink.MODEL_1in54)
	eink.setup(1, 0,pin.PB00,pin.PB03,pin.PB01,pin.PB04)
	eink.setWin(200, 200, 0)--设置窗口大小
	log.info("更新刷新模式")
		eink.setFont(fonts.get("oppo_light_12")) 
	sys.wait(60000)
	eink.model(eink.MODEL_1in54)
	eink.setup(0, 0,pin.PB00,pin.PB03,pin.PB01,pin.PB04)
	eink.setWin(200, 200, 0)--设置窗口大小
	log.info("更新刷新模式")
		eink.setFont(fonts.get("oppo_light_12")) 
		sys.wait(5000)
end
end)


sys.taskInit(function() --读取文件菜单 并显示 任务
		menuflag = 1--表示正处于目录界面
		caidanflag = 0

		log.info('开始显示菜单')

		local ret, data = io.lsdir("/sd", 10, 0)
		if ret then

			n1,n2 = string.gsub(json.encode(data), "name","name")--n2是所含文件数
			log.info("文件数量", n2)
			wenjianshu = n2
				while wenjianshu > 0 do
				wenjianming = data[wenjianshu].name--获取文件名
				c1,c2 = string.gsub(wenjianming, "TXT","TXT")
				eink.circle(12, 23, 5,0,1)
					if c2 > 0 then
						log.info("匹配到一个！")
						c2 = 0
						t[cc] = wenjianming --标记文件名
						cc = cc + 1
						eink.print(20, wenjianmingweizhi, wenjianming)
						wenjianmingweizhi = wenjianmingweizhi + 20
					end
					wenjianshu = wenjianshu - 1
				end
				nn = cc
				wenjianzongshu = nn
				cc = 0
				wenjianmingweizhi = 30
				eink.show()
				eink.clear()
				mubiaoshu = 0
			log.info("fs", "lsdir", json.encode(data))


			
		end

		if n2 == 0 then
			log.info("fs", "lsdir", "fail", ret, data)
			eink.print(40, 50, "商量一下插个卡吧~")
			eink.print(80, 80, "或者")
			eink.print(30, 110, "你卡里没有TXT文件哦")
			eink.show()
		end

end)

sys.taskInit(function() --读取文件菜单 并显示 任务

	

	while sys.waitUntil("go_mulu") do
		menuflag = 1--表示正处于菜单界面
		caidanflag = 0

		log.info('开始显示菜单')

		local ret, data = io.lsdir("/sd", 10, 0)
		if ret then

			n1,n2 = string.gsub(json.encode(data), "name","name")--n2是所含文件数
			log.info("文件数量", n2)
			wenjianshu = n2
				while wenjianshu > 0 do
				wenjianming = data[wenjianshu].name--获取文件名
				c1,c2 = string.gsub(wenjianming, "TXT","TXT")
				eink.circle(12, 23, 5,0,1)
					if c2 > 0 then
						log.info("匹配到一个！")
						c2 = 0
						t[cc] = wenjianming --标记文件名
						cc = cc + 1
						eink.print(20, wenjianmingweizhi, wenjianming)
						wenjianmingweizhi = wenjianmingweizhi + 20
					end
					wenjianshu = wenjianshu - 1
				end
				nn = cc
				wenjianzongshu = nn
				log.info("有文件",wenjianzongshu,"个")
				cc = 0
				wenjianmingweizhi = 30
				eink.show()
				eink.clear()
				mubiaoshu = 0
			log.info("fs", "lsdir", json.encode(data))
		end
	end
end)

sys.taskInit(function() --下一本
    while sys.waitUntil("go_down") do
        log.info("下一个！！！")
        eink.clear()
		shubiao = shubiao + 20
		if shubiao > ((wenjianzongshu - 1) * 20) + 23 then
			shubiao = 23
		end 
		eink.circle(12, shubiao, 5,0,1)
            while nn > 0 do
                eink.print(20, wenjianmingweizhi, t[cc])
                cc = cc + 1
                wenjianmingweizhi = wenjianmingweizhi + 20
                nn = nn - 1
            end
        cc = 0
        nn = wenjianzongshu
        wenjianmingweizhi = 30
        mubiaoshu = mubiaoshu + 1
		if mubiaoshu < 0 then
			mubiaoshu = wenjianzongshu - 1
		end
        log.info(t[mubiaoshu])
        eink.show()
        menuflag = 1
    end
end)

sys.taskInit(function() --上翻一本
    while sys.waitUntil("go_up") do
        log.info("上一个！！！")
		eink.clear()
        shubiao = shubiao - 20
		if shubiao < 23 then
			shubiao = ((wenjianzongshu - 1) * 20) + 23
		end 
        eink.circle(12, shubiao, 5,0,1)
            while nn > 0 do
                eink.print(20, wenjianmingweizhi, t[cc])
                cc = cc + 1
                wenjianmingweizhi = wenjianmingweizhi + 20
                nn = nn - 1
            end
        cc = 0
        nn = wenjianzongshu
        wenjianmingweizhi = 30
        mubiaoshu = mubiaoshu - 1
			if mubiaoshu > wenjianzongshu - 1 then
				mubiaoshu = 0
			end
        log.info(t[mubiaoshu])
        eink.show()
        menuflag = 1
    end
end)



	sys.taskInit(function() --显示下一页
		--一行十一个字，33字节
		while sys.waitUntil("go_next") do

			while yiduanhangshu > 0 do

				log.info("剩余",yiduanhangshu,"行")
				
				if yiduanhangshu > 1 and yiduanhangshu < hangshuflag then --正常显示
					bookmark = bookmark + 33 --书签增加
					goback = goback + 33 --本页字符
					heihei = tostring(book:read(33))
					eink.print(5, weizhi, heihei)
					log.info("进入显示")
					yiduanhangshu = yiduanhangshu - 1
					weizhi = weizhi + 20

						if weizhi == 210  then
							n = n + 1
							eink.print(0, 10, n)
							eink.show()
							log.info("共显示了",bookmark,"个字符")
							log.info("本页共",goback,"个字符")
							break
						end

				end
				
				if yiduanhangshu == 1 and hangshuflag > 1 then  --最后一段显示
					log.info("开始显示最后一行",zuihouyihangzishu,"字")
					bookmark = bookmark + zuihouyihangzishu --书签增加
					goback = goback + zuihouyihangzishu --本页字符
					heihei = tostring(book:read(zuihouyihangzishu))
					eink.print(5, weizhi, heihei)
					yiduanhangshu = yiduanhangshu - 1
					book:seek ("cur" , 2 )--挪置光标于下一段开头
					weizhi = weizhi + 20

						if weizhi == 210  then --超出显示范围或者一段显示完成后开始加载第二段
							n = n + 1
							eink.print(0, 10, n)
							eink.show()
							log.info("共显示了",bookmark,"个字符")
							log.info("本页共",goback,"个字符")
							break
						end

						if weizhi < 210 then
							sys.publish("next_part") 
						end

				end

				if yiduanhangshu == hangshuflag and yiduanhangshu ~= 1 and x2 == 4 then  --第一行显示
					log.info("开始显示第一行")
					
							bookmark = bookmark + 34 --书签增加34
							goback = goback + 34 --本页字符
							heihei = tostring(book:read(34))--需要显示首行缩进
							eink.print(5, weizhi, heihei)
							yiduanhangshu = yiduanhangshu - 1
							weizhi = weizhi + 20
								if weizhi == 210  then
									n = n + 1
									eink.print(0, 10, n)
									eink.show()
									log.info("共显示了",bookmark,"个字符")
									log.info("本页共",goback,"个字符")
									break
								end
				end

				if yiduanhangshu == hangshuflag and yiduanhangshu ~= 1 and x2 ~= 4 then  --新一页第一行的并非一段首句
					log.info("开始显示第一行但不是第一句")
					bookmark = bookmark + 33 --书签增加33
					goback = goback + 33 --本页字符
					heihei = tostring(book:read(33))--不需要显示首行缩进
					eink.print(5, weizhi, heihei)
					yiduanhangshu = yiduanhangshu - 1
					weizhi = weizhi + 20
						if weizhi == 210  then
							n = n + 1
							eink.print(0, 10, n)
							eink.show()
							log.info("共显示了",bookmark,"个字符")
							log.info("本页共",goback,"个字符")
							break
						end
				end


				if hangshuflag == 1 then  --唯一一行显示
					bookmark = bookmark + zuihouyihangzishu --书签增加
					goback = goback + zuihouyihangzishu --本页字符
						log.info("开始显示唯一一行")
						heihei = tostring(book:read(zuihouyihangzishu))
						eink.print(5, weizhi, heihei)
						yiduanhangshu = yiduanhangshu - 1
						weizhi = weizhi + 20

							if weizhi == 210  then
								n = n + 1
								eink.print(0, 10, n)
								eink.show()
								log.info("共显示了",bookmark,"个字符")
								log.info("本页共",goback,"个字符")
								break
							end

							if weizhi < 210 then
								sys.publish("next_part") 
							end
				end
			end
		end
end)

sys.taskInit(function()------------------------------------------------------------------菜单显示
	while sys.waitUntil("go_caidan") do
		eink.clear()
		eink.circle(12, caidancircle, 5,0,1)
		eink.print(20, 30, "继续阅读")
		eink.print(20, 50, "存书签")
		eink.print(20, 70, "回目录")
		log.info(suoxuanxiang , "是目前选项")
		eink.show()
	end
end)



	sys.taskInit(function()--------------------------------------------------------------------------------按键

			while 1 do

                
				if gpio.get(4) == 0 and flag == 0 and menuflag == 1 then--确认
					sys.wait(100)
					log.info('进入1')

					if gpio.get(4) == 0 then
						log.info('确认按键成功')
						weizhi = 30--重置显示位置
                        str1 = "/sd/"
                        opened = str1 .. t[mubiaoshu]
                        log.info("打开",opened)
                        book = io.open(opened)
						if fdb.kv_get(opened) ~= nil then
							book:seek ("cur" , fdb.kv_get(opened))
						end
						
						eink.clear()--清屏
						sys.publish("next_part")
						log.info('进入阅读')
						flag = 1--进入读书
                        menuflag = 0 --退出目录
					end
				end


				if gpio.get(7) == 0 and menuflag == 1 then --下一本

                    sys.wait(100)
                    log.info('下一本')

                    if gpio.get(7) == 0 and menuflag == 1 then
                        eink.clear()--清屏
                        sys.publish("go_down")
            
                    end

                end
                if gpio.get(1) == 0 and menuflag == 1 then --上一本

                    sys.wait(100)
                    log.info('下一本')

                    if gpio.get(1) == 0 and menuflag == 1 then
                        eink.clear()--清屏
                        sys.publish("go_up")
            
                    end

                end

				if gpio.get(4) == 0 and flag == 1 and menuflag == 0 and caidanflag == 0 then--读书期间进入菜单
					sys.wait(100)
					log.info('进入菜单')
					if gpio.get(4) == 0 then

						-- eink.model(eink.MODEL_1in54)
						-- eink.setup(1, 0,pin.PB00,pin.PB03,pin.PB01,pin.PB04)
						-- eink.setWin(200, 200, 0)--设置窗口大小
						-- log.info("eink", "end setup")
						-- log.info("e-paper 1.54", "Testing Go")
						-- eink.clear()--清屏
						-- eink.setFont(fonts.get("oppo_light_12")) 

						caidanxuanxiang = 2
						weizhi = 30--重置显示位置、
						caidancircle = 43--更新圆显示位置
						--suoxuanxiang = 0 --重置所选项
						flag = 0--推出读书
                        menuflag = 0 --退出目录状态
						caidanflag = 1--进入菜单状态
						-- sys.publish("go_caidan")
						eink.clear()
						eink.circle(12, caidancircle, 5,0,1)
						eink.print(20, 30, "继续阅读")
						eink.print(20, 50, "存书签")
						eink.print(20, 70, "回目录")
						log.info(caidanxuanxiang , "是目前选项")
						eink.show()
						log.info('进入菜单成功')
						--- 1、存书签
						--- 2、回到本书
						--- 3、回到主目录
					end
				end

				if gpio.get(4) == 0 and flag == 0 and menuflag == 0 and caidanflag == 1 then--进入菜单期间选择
					sys.wait(100)
					log.info('进入菜单')
					if gpio.get(4) == 0 then



						if caidanxuanxiang == 2 then--存书签
							if fdb.kv_get(opened) ~= nil then
								bookmark = bookmark + fdb.kv_get(opened) - goback
								fdb.kv_del(opened)

							end
							log.info('看到了',fdb.kv_get(opened))
							fdb.kv_set(opened, bookmark)--书名，字符数
							log.info('书签存储成功',fdb.kv_get(opened))
							bookmark = 0
							caidanxuanxiang = 1
							eink.clear()
							eink.print(50, 50, "书签存入成功")
							eink.print(30, 80, "按下确认键继续阅读")
							eink.show()
							sys.wait(100)
						end
						
						if caidanxuanxiang == 1 then--回本书
							book:seek ("cur" , - goback)
							sys.wait(100)
							flag = 1 --读书标志
							sys.publish("next_part")
						end

						if caidanxuanxiang == 3 then --回目录
							bookmark = 0
							goback = 0
							mubiaoshu = 0
							sys.publish("go_mulu")
							menuflag = 1 --目录标志
						end
						caidanxuanxiang = 1
						caidanflag = 0 --退出菜单
						eink.clear()
					end
				end
				
				if gpio.get(7) == 0 and caidanflag == 1 then--菜单下调

					sys.wait(100)
					log.info('进入1')
						if gpio.get(7) == 0 and caidanflag == 1 then
							caidanxuanxiang = caidanxuanxiang + 1
							caidancircle = caidancircle + 20
							--suoxuanxiang = suoxuanxiang + 1
							sys.publish("go_caidan")

						end
				end

				if gpio.get(1) == 0 and caidanflag == 1 then--菜单上调

					sys.wait(100)
					log.info('进入1')
						if gpio.get(1) == 0 and caidanflag == 1 then
							caidanxuanxiang = caidanxuanxiang - 1
							caidancircle = caidancircle - 20
							--suoxuanxiang = suoxuanxiang - 1
							sys.publish("go_caidan")

						end
				end

				if gpio.get(7) == 0 and flag == 1 then--翻页——下一页

					sys.wait(50)
					log.info('进入1')
					-- sys.wait(20)

					if gpio.get(7) == 0 then
						shuaxinflag = shuaxinflag + 1

						shuaxinflag = shuaxinflag + 1
						bookmark0 = bookmark 
						log.info('按键成功')
						weizhi = 30--重置显示位置
						-- sys.publish("go_next")
						sys.wait(100)
						sys.publish("next_part")
						eink.clear()--清屏
						log.info('执行翻页')
						goback = 0
						markflag = 1
					end
				end




				if gpio.get(1) == 0 and flag == 1 then--上一页
					sys.wait(50)
					log.info('进入1')
					if gpio.get(1) == 0 then
						book:seek ("cur" , -goback )
						weizhi = 30--重置显示位置
						eink.clear()--清屏
						backflag = 0
						backflag0 = 280
						book:seek ("cur" , -backflag0 )
						sys.publish("yest_part")
					end
				end


			end
	end)


	sys.taskInit(function()--往回返一页显示
		while sys.waitUntil("go_yest")  do
			while yiduanhangshu > 0 do
				if yiduanhangshu > 1 and yiduanhangshu < hangshuflag then --正常显示
					backflag = backflag + 33 --此页字符数标志
					heihei = tostring(book:read(33))
					eink.print(5, weizhi, heihei)
					yiduanhangshu = yiduanhangshu - 1
					weizhi = weizhi + 20
						if weizhi == 210  then --此页读取完成
							

							
							--redo
							if backflag < backflag0 then
								weizhi = 30
								book:seek ("cur" , 0 - backflag + 1 )
								backflag0 = backflag0 - 1--回调数量
								backflag = 0
								eink.clear()--清屏
								sys.publish("yest_part")
								break
                            else
								n = n - 1
								eink.print(0, 10, n)
								eink.show()
								log.info("进入显示")
								log.info("以此为起点读到",backflag,"个字符")
								break
							end
						end

				end
				
				if yiduanhangshu == 1 and hangshuflag > 1 then  --最后一段显示
					backflag = backflag + zuihouyihangzishu --此页字符数标志
					heihei = tostring(book:read(zuihouyihangzishu))
					eink.print(5, weizhi, heihei)
					yiduanhangshu = yiduanhangshu - 1
					book:seek ("cur" , 2 )--挪置光标于下一段开头
					weizhi = weizhi + 20
						if weizhi == 210  then --超出显示范围或者一段显示完成后开始加载第二段
							

							
							if backflag < backflag0 then
								weizhi = 30
								book:seek ("cur" , 0 - backflag + 1 )
								backflag0 = backflag0 - 1
								backflag = 0
								eink.clear()--清屏
								sys.publish("yest_part")
								break
							else
								n = n - 1
								eink.print(0, 10, n)
								eink.show()
								log.info("以此为起点读到",backflag,"个字符")
								break
							end
						end

						if weizhi < 210 then
							sys.publish("yest_part") 
						end

				end

				if yiduanhangshu == hangshuflag and yiduanhangshu ~= 1 and x2 == 4 then  --第一行显示
							backflag = backflag + 34 --此页字符数标志
							heihei = tostring(book:read(34))--需要显示首行缩进
							eink.print(5, weizhi, heihei)
							yiduanhangshu = yiduanhangshu - 1
							weizhi = weizhi + 20
								if weizhi == 210  then
									

									
									if backflag < backflag0 then
										weizhi = 30
										book:seek ("cur" , 0 - backflag + 1 )
										backflag0 = backflag0 - 1
										backflag = 0
										eink.clear()--清屏
										sys.publish("yest_part")
										break
									else
										n = n - 1
										eink.print(0, 10, n)
										eink.show()
										log.info("以此为起点读到",backflag,"个字符")
										break
									end
								end
				end

				if yiduanhangshu == hangshuflag and yiduanhangshu ~= 1 and x2 ~= 4 then  --新一页第一行的并非一段首句
					backflag = backflag + 33 --此页字符数标志
					heihei = tostring(book:read(33))--不需要显示首行缩进
					eink.print(5, weizhi, heihei)
					yiduanhangshu = yiduanhangshu - 1
					weizhi = weizhi + 20
						if weizhi == 210  then
							

							
							if backflag < backflag0 then
								weizhi = 30
								book:seek ("cur" , 0 - backflag + 1 )
								backflag0 = backflag0 - 1
								backflag = 0
								eink.clear()--清屏
								sys.publish("yest_part")
								break
							else
								n = n - 1
								eink.print(0, 10, n)
								eink.show()
								log.info("以此为起点读到",backflag,"个字符")
								break
							end
						end
				end


				if hangshuflag == 1 then  --唯一一行显示
					backflag = backflag + zuihouyihangzishu --此页字符数标志
						heihei = tostring(book:read(zuihouyihangzishu))
						eink.print(5, weizhi, heihei)
						yiduanhangshu = yiduanhangshu - 1
						weizhi = weizhi + 20

							if weizhi == 210  then
								

								
								if backflag < backflag0 then
									weizhi = 30
									book:seek ("cur" , 0 - backflag + 1 )
									backflag0 = backflag0 - 1
									backflag = 0
									eink.clear()--清屏
									sys.publish("yest_part")
									break
								else
									n = n - 1
									eink.print(0, 10, n)
									eink.show()
									log.info("以此为起点读到",backflag,"个字符")
									break
								end

							end

							if weizhi < 210 then
								sys.publish("yest_part")--？ 
							end
				end
			end
		end

	end)

	sys.taskInit(function()--回返之后的读取
		while sys.waitUntil("yest_part") do
			yiduan = tostring(book:read("L"))--正常读取一段
			yiduanchangdu = string.len(yiduan)
			--------空行跳过
				if yiduanchangdu == 2 and yiduan == "/n" then
					log.info("读取的第",x,"段","是空行")
					backflag = backflag + 2
					yiduan = tostring(book:read("L"))--重新读取
					x = x + 1
					log.info("读取的是第",x,"段")
					yiduanchangdu = string.len(yiduan)--计算一段字符串的长度
					log.info('此段拥有字符',yiduanchangdu)
					log.info('内容为',yiduan)
						if yiduanchangdu == 2 and yiduan == "/n"then
							log.info("读取的第",x,"段","是空行")
							backflag = backflag + 2
							yiduan = tostring(book:read("L"))--重新读取
							x = x + 1
							log.info("读取的是第",x,"段")
							yiduanchangdu = string.len(yiduan)--计算一段字符串的长度
							log.info('此段拥有字符',yiduanchangdu)
							log.info('内容为',yiduan)
						end 
				end 
			-----------------------空行跳过
			yiduanzishu =  (yiduanchangdu - 3) / 3
			yiduanhangshu = math.floor (yiduanzishu / 11)
			yiduanhangshu = yiduanhangshu + 1 
			hangshuflag = yiduanhangshu
			zuihouyihangzishu = yiduanchangdu - 33 * (yiduanhangshu - 1)
			book:seek ("cur" , 0 - yiduanchangdu  )--回到段首
			shouhangsuojin = tostring(book:read(4)) --判断首句
			x1 , x2 = string.gsub (shouhangsuojin , " " , " ")
			book:seek ("cur" , -4 )--回到段首
			sys.publish("go_yest")
		end
	end)


	sys.taskInit(function()--正常读取下一页
		while sys.waitUntil("next_part") do
			yiduan = tostring(book:read("L"))
				if yiduan == nil then
					eink.show()
					break
				end
			x = x + 1
			log.info("读取的是第",x,"段")
			yiduanchangdu = string.len(yiduan)--计算一段字符串的长度
			log.info('此段拥有字符',yiduanchangdu,"个")
			log.info('内容为',yiduan)

				if yiduanchangdu == 2 then
					log.info("读取的第",x,"段","是空行")
					bookmark = bookmark + 2
					yiduan = tostring(book:read("L"))--重新读取
					x = x + 1
					log.info("读取的是第",x,"段")
					yiduanchangdu = string.len(yiduan)--计算一段字符串的长度
					log.info('此段拥有字符',yiduanchangdu)
					log.info('内容为',yiduan)
						if yiduanchangdu == 2 then
							log.info("读取的第",x,"段","是空行")
							bookmark = bookmark + 2
							yiduan = tostring(book:read("L"))--重新读取
							x = x + 1
							log.info("读取的是第",x,"段")
							yiduanchangdu = string.len(yiduan)--计算一段字符串的长度
							log.info('此段拥有字符',yiduanchangdu)
							log.info('内容为',yiduan)
						end 
				end 
				----非纯文字的计算
				--开始
			yiduanzishu =  (yiduanchangdu - 3) / 3
			yiduanhangshu = math.floor (yiduanzishu / 11)
			yiduanhangshu = yiduanhangshu + 1 
			hangshuflag = yiduanhangshu
			zuihouyihangzishu = yiduanchangdu - 33 * (yiduanhangshu - 1)
			log.info("计算完成，本段有",yiduanhangshu,"行")
			log.info("最后一行字数",zuihouyihangzishu,"个")
			book:seek ("cur" , 0 - yiduanchangdu  )--回到段首

			shouhangsuojin = tostring(book:read(4)) --判断首句
			x1 , x2 = string.gsub (shouhangsuojin , " " , " ")
			book:seek ("cur" , -4 )--回到段首
			log.info(x1,x2)
			sys.publish("go_next")

		end
	end)

	sys.run()
