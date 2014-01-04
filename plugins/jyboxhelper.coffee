HELP_INFO = """
    ~time            #显示时间
    ~rule 1.1        #查询群规则
    ~rule update     #从 Gist 更新群规则
    ~stat            #查询妹子比例
    ~help            #查询帮助文档
    ~uptime          #服务运行时间
"""

request = require('request')
Path = require 'path'
fs = require 'fs'

# 毫秒亲
start_at = new Date().getTime()
###
 @param content 消息内容
 @param send(content)  回复消息
 @param robot qqbot instance
 @param message 原消息对象
###

# 问题：方式不优雅，应该是一个模式识别成功，别的就不应调用到
module.exports = (content ,send, robot, message)->


    if content.match /^~help$/i
        send HELP_INFO

    if content.match /^~plugins$/i
        send "插件列表：\n" + robot.dispatcher.plugins.join('\r\n')

    if content.match /^~time$/i
        send "冥王星引力精准校时：" + new Date()

    # ret = content.match /^echo (.*)/i
    # if ret
    #     send "哈哈，" + ret[1]

    # 统计女性成员比例
    if content.match /^~stat$/i
      stat = {}
      for member in robot.groupmember_info[message.from_gid].minfo
        stat[member.gender] = (stat[member.gender] or 0) + 1
      percent = Math.round(stat.female / (stat.male + stat.female) * 100)
      send "汉子：#{stat.male} 妹子：#{stat.female} 未知：#{stat.unknown} 妹子比例：#{percent}%"

    # 妹子出现提示
    if message.from_user and message.from_user.gender is "female" and (!last_sound_time or last_sound_time <= +new Date - 60*5*1000)
      send "☆ω☆ 妹子出现，请注意！"
      last_sound_time = +new Date

    # 查询群规则
    api_url = "https://api.github.com/gists/6608448"
    rule_file_path = Path.join __dirname, "..", "tmp/QQ-Qun.md"
    rule_id = content.match /^~rule (.*)/i
    if rule_id
      if rule_id[1] is 'update'
        request
          url: api_url
          strictSSL: false
          timeout: 5000
          headers:
            'User-Agent': 'JYBOX'
        , (error, response, body) ->
          unless error
            data = JSON.parse body.trim()
            rules_content = data.files['QQ-Qun.md'].content
            fs.writeFileSync rule_file_path, rules_content
            send "规则更新成功，更新的规则版本为 #{data.updated_at}"
      else
        # 查询规则
        rules = fs.readFileSync rule_file_path, 'utf8'
        re = new RegExp("\\(#{rule_id[1]}\\)([^\n]+)\n")
        matchs = rules.match re
        if matchs
          send matchs[1].trim()
        else
          send "╭(╯^╰)╮，没有找到这条规则哦，完整的规则请看：https://gist.github.com/jysperm/6608448"
        
    if content.match /^~uptime$/i
      secs = (new Date().getTime() - start_at) / 1000
      aday  = 86400 
      ahour = 3600
      [day,hour,minute,second] = [secs/ aday,secs%aday/ ahour,secs%ahour/ 60,secs%60].map (i)-> parseInt(i)
      send "up #{day} days, #{hour}:#{minute}:#{second}"