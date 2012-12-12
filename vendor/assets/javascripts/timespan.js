Date.create = function(p_Date, format){
  var dateFormat = dateFormat || "DD/MM/YYYY";
  if (jQuery.type(p_Date) === 'string') {
    var secs = moment(p_Date, dateFormat).valueOf();
    return new Date(secs);    
  }
  return p_Date;
}

Date.timeleft = function(fromDate, toDate){
  var now = Date.create(fromDate);
  var end = Date.create(toDate);

  if(now >= end){
    [now, end] = [end, now]
  }

  yr = now.getYear();
  if(now.getYear() < 1900)
    yr = now.getYear() + 1900;

  var dy = end.getDate() - now.getDate();
  var mnth = end.getMonth() - now.getMonth();
  var yr = end.getFullYear() - yr;
  var daysinmnth = 32 - new Date(now.getYear(),now.getMonth(), 32).getDate();

  if(dy < 0){
    dy = (dy+daysinmnth)%daysinmnth;
    mnth--; 
  }
  if(mnth < 0){
    mnth = (mnth+12)%12;
    yr--;
  } 

  var wk = 0;
  if(dy > 7){
    wk = Math.floor(dy / 7);
    dy = dy % 7;
  } 

  return Date.formatDuration(yr, mnth, wk, dy);
}
Date.period = Date.timeleft;
Date.duration = Date.timeleft;
Date.timespan = Date.timeleft;

 
String.prototype.formatStr = function() {
    var formatted = this;
    for (var i = 0; i < arguments.length; i++) {
        var regexp = new RegExp('\\{'+i+'\\}', 'gi');
        formatted = formatted.replace(regexp, arguments[i]);
    }
    return formatted;
};

Date.formatDuration = function(years, months, weeks, days) {

  var pluralis = function(number, unit) {
    if (number == 1)
      return number.toString() + ' ' + unit;
    return number.toString() + ' ' + unit + 's';
  }

  var list = [];

  // TODO: support localization!
  if (years > 1)
    list.push(pluralis(years, 'year'));
  if (months > 0)
    list.push(pluralis(months, 'month'));
  if (weeks > 0)
    list.push(pluralis(weeks, 'week'));
  if (days > 0)
    list.push(pluralis(days, 'day'));

  var lastPartStr = list[list.length - 1];  
  var parts = list.slice(0, list.length -1);
  var partStr = parts.join(', ');

  return parts.length == 0 ? lastPartStr : (partStr + ' and ' + lastPartStr);
}