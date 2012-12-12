/*  DepressedPress.com DP_DateExtensions

Author: Jim Davis, the Depressed Press of Boston
Date: June 20, 2006
Contact: webmaster@depressedpress.com
Website: www.depressedpress.com

Full documentation can be found at:
http://www.depressedpress.com/Content/Development/JavaScript/Extensions/

DP_DateExtensions adds features to the JavaScript "Date" datatype.

Copyright (c) 1996-2013, The Depressed Press of Boston (depressedpress.com)

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

+) Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

+) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

+) Neither the name of the DEPRESSED PRESS OF BOSTON (DEPRESSEDPRESS.COM) nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* "Date" Object Extensions */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

  // Date.DP_DateExtensions
  // Simple static variable allowing code to determine if DP_DateExtentions have been loaded.
Date.DP_DateExtensions = true;

  // Set the First Day of Week (Sunday=0, Default)
Date.FirstDayOfWeek = 0;

  // Set the Multiplication factors for unambigiuos times (MS times, used by various internal functions)
Date.Factors = new Object();
Date.Factors.milliseconds = 1;    // 1 ms to the ms
Date.Factors.seconds = 1000;    // 1000 ms to the second (1 * 1000)
Date.Factors.minutes = 60000;   // 60 seconds to the minute (1 * 1000 * 60)
Date.Factors.quarterhours = 900000; // 15 minutes to the quarter hour (1 * 1000 * 60 * 15)
Date.Factors.warhols = 900000;    // 15 minutes of fame (1 * 1000 * 60 * 15)
Date.Factors.halfhours = 1800000; // 30 minutes to the half hour (1 * 1000 * 60 * 15)
Date.Factors.hours = 3600000;   // 60 minutes to the hour (1 * 1000 * 60 * 60)
Date.Factors.days = 86400000;   // 24 hours to the day (1 * 1000 * 60 * 60 * 24)
Date.Factors.weeks = 604800000;   // 7 days per week (1 * 1000 * 60 * 60 * 24 * 7)

  // is
  // Checks if an object is a Date object
Date.is = function(Ob) {
  try {
    if ( typeof Ob == "object" ) {
      if ( Ob.constructor == Date ) {
        return true;
      };
    };
  } catch (CurError) { };
  return false;
};


  // parseFormat
  // Accepts a date/time format and a string and returns either a date (if the format matches) or null
Date.parseFormat = function(CurDate, Mask, DefaultTo, CenturyMark) {

    // Check the input parameters
  if ( typeof CurDate != "string" || CurDate == "" ) {
    return null;
  };
  if ( typeof Mask != "string" || Mask == "" ) {
    return null;
  };
  if ( typeof DefaultTo != "number" && DefaultTo != 0 && DefaultTo != 1 && DefaultTo != 2 ) {
    DefaultTo = 0;
  };
  if ( typeof CenturyMark != "number" || CenturyMark < 0 || CenturyMark > 99 ) {
    CenturyMark = 50;
  };

    // Set Mask Characters
  var MaskChars = "DMYhHmsltTz";
    // SetRegEx chars (these need to be escaped in the Mask)
  var RegExChars = "^$.*+?=!:|\\/()[]{}-";
    // Set a reference object for month names
  var MonthRef = {jan:0,feb:1,mar:2,apr:3,may:4,jun:5,jul:6,aug:7,sep:8,oct:9,nov:10,dec:11}
    // Begin the RegEx
  var RegEx = "";
    // Tack a temporary space at the end of the mask to ensure that the last character isn't a mask character
  Mask += " ";

    // Default the positions of the date fragments
    // 0 = year, 1 = month, 2 = day, 3 = hour, 4 = minute, 5 = second, 6 = millisecond, 7 = ampmind, 8 = TimeZone
  var DF = [null,null,null,null,null,null,null, null];

    // Parse the Mask
  var CurChar;
  var MaskPart = "";
  var MaskPartCnt = 1;
    // Loop over the mask, character by character
  for ( var Cnt = 0; Cnt < Mask.length; Cnt++ ) {
      // Get the character
    CurChar = Mask.charAt(Cnt);
      // Determine if the character is a mask element
    if ( ( MaskChars.indexOf(CurChar) == -1 ) || ( MaskPart != "" && CurChar != MaskPart.charAt(MaskPart.length - 1) ) ) {
        // Determine if we need to parse a MaskPart or not
      if ( MaskPart != "" ) {
          // Set the position of the mask part
        switch (MaskPart) {
          case "YY":
          case "YYYY":
            DF[0] = MaskPartCnt;
            break;
          case "M":
          case "MM":
          case "MMM":
          case "MMMM":
            DF[1] = MaskPartCnt;
            break;
          case "D":
          case "DD":
          case "DDD":
          case "DDDD":
            DF[2] = MaskPartCnt;
            break;
          case "h":
          case "hh":
          case "H":
          case "HH":
            DF[3] = MaskPartCnt;
            break;
          case "m":
          case "mm":
            DF[4] = MaskPartCnt;
            break;
          case "s":
          case "ss":
            DF[5] = MaskPartCnt;
            break;
          case "l":
            DF[6] = MaskPartCnt;
            break;
          case "t":
          case "T":
          case "tt":
          case "TT":
            DF[7] = MaskPartCnt;
            break;
          case "z":
            DF[8] = MaskPartCnt;
            break;
        };
          // Convert the mask part to a regex fragment
        switch (MaskPart) {
          case "h":
            RegEx += "(1[0-2]|[1-9])";
            break;
          case "hh":
            RegEx += "(1[0-2]|0[1-9])";
            break;
          case "H":
            RegEx += "(2[0-4]|1[0-9]|[0-9])";
            break;
          case "HH":
            RegEx += "(2[0-4]|1[0-9]|0[0-9])";
            break;
          case "s":
          case "m":
            RegEx += "([0-5]?[0-9])";
            break;
          case "ss":
          case "mm":
            RegEx += "([0-5]?[0-9])";
            break;
          case "l":
            RegEx += "([0-9]+)";
            break;
          case "t":
          case "T":
            RegEx += "(a|p)";
            break;
          case "tt":
          case "TT":
            RegEx += "(am|pm)";
            break;
          case "D":
            RegEx += "((?:3[01])|(?:[12][0-9])|(?:0[1-9])|[1-9])";
            break;
          case "DD":
            RegEx += "((?:3[01])|(?:[12][0-9])|(?:0[1-9]))";
            break;
          case "DDD":
            RegEx += "(sun|mon|tue|wed|thu|fri|sat)";
            break;
          case "DDDD":
            RegEx += "(sunday|monday|tuesday|wednesday|thursday|friday|saturday)";
            break;
          case "M":
            RegEx += "((?:1[012])|(?:0[1-9])|[1-9])";
            break;
          case "MM":
            RegEx += "((?:1[012])|(?:0[1-9]))";
            break;
          case "MMM":
            RegEx += "(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)";
            break;
          case "MMMM":
            RegEx += "(january|february|march|april|may|june|july|august|september|october|november|december)";
            break;
          case "YY":
            RegEx += "([0-9]{2})";
            break;
          case "YYYY":
            RegEx += "((?:1[6-9]|[2-9][0-9])[0-9]{2})";
            break;
          case "z":
            RegEx += "(Z|UT|[\+\-](?:1[012]|[0]?[0-9])(?::?[0-5]?[0-9]))";
            break;
        };
          // Reset the MaskPart to nothing
        MaskPart = "";
          // Increment the count of discovered mask parts
        MaskPartCnt++;
      };
        // If the char is a mask char, start a new mask part, otherwise, dump it to the output
      if ( MaskChars.indexOf(CurChar) > -1 ) {
        MaskPart = CurChar;
      } else {
          // The character isn't a mask character
        if ( RegExChars.indexOf(CurChar) >= 0 ) {
          RegEx += "\\";
        };
        RegEx += CurChar;
      };
    } else {
        // Add the current mask character to the MaskPart
      MaskPart += CurChar;
    };
  };
    // Remove the temporary space from the end of the formatted date
  RegEx = RegEx.substring(0,RegEx.length - 1);

    // Try to parse the input
  var ParsedDF;
  if (ParsedDF = new RegExp("^" + RegEx + "$", "i").exec(CurDate)) {};
    // If the date couldn't be parsed, return null
  if ( !ParsedDF ) { return null };
    // Replace the date fragment positions with the actual dates

  for (var Cnt = 0; Cnt < DF.length; Cnt++) {
    if ( DF[Cnt] != null ) {
      DF[Cnt] = ParsedDF[DF[Cnt]];
    };
  };

    // Set Month, if present
  if ( DF[1] != null ) {
    var CurDF = MonthRef[DF[1].substring(0,3).toLowerCase()];
    if ( CurDF != null ) {
      DF[1] = CurDF;
    } else {
      DF[1] = DF[1]-1;
    };
  };


    // Handle two digit years, if present
  if ( DF[0] != null && DF[0] < 100 ) {
    var CurDF = DF[0] * 1;
    if ( CurDF < CenturyMark ) {
      DF[0] = parseInt(CurDF, 10) + 2000;
    } else {
      DF[0] = parseInt(CurDF, 10) + 1900;
    };
  };


    // Set AM/PM, if present (Hours must be present and less than 12 for it to matter)
  if ( DF[7] != null && DF[3] != null ) {
    var CurAP = DF[7].substring(0,1).toLowerCase();
    if ( CurAP == "p" ) {
        // Add 12 if PM and hours is less than 12 (use parseInt to ensure that values with leading zeroes are not mistaken for strings)
      if ( DF[3] < 12 ) {
        DF[3] = parseInt(DF[3], 10) + 12;
      };
    } else {
        // 12 AM is zero, not 12
      if ( DF[3] == 12 ) {
        DF[3] = 0;
      };
    };
  };

    // Set defaults for null date parts
  if ( DefaultTo == 0 ) {
    // No changes needed for this default
  } else if ( DefaultTo == 1 ) {
      // Set the Current Date Parts
    var NowDate = new Date();
    if ( DF[0] == null ) { DF[0] = NowDate.getFullYear() };
    if ( DF[1] == null ) { DF[1] = NowDate.getMonth() };
    if ( DF[2] == null ) { DF[2] = NowDate.getDate() };
    if ( DF[3] == null ) { DF[3] = NowDate.getHours() };
    if ( DF[4] == null ) { DF[4] = NowDate.getMinutes() };
    if ( DF[5] == null ) { DF[5] = NowDate.getSeconds() };
    if ( DF[6] == null ) { DF[6] = NowDate.getMilliseconds() };
  } else if ( DefaultTo == 2 ) {
    var NowDate = new Date();
    if ( DF[0] == null ) { DF[0] = NowDate.getUTCFullYear() };
    if ( DF[1] == null ) { DF[1] = NowDate.getUTCMonth() };
    if ( DF[2] == null ) { DF[2] = NowDate.getUTCDate() };
    if ( DF[3] == null ) { DF[3] = NowDate.getUTCHours() };
    if ( DF[4] == null ) { DF[4] = NowDate.getUTCMinutes() };
    if ( DF[5] == null ) { DF[5] = NowDate.getUTCSeconds() };
    if ( DF[6] == null ) { DF[6] = NowDate.getUTCMilliseconds() };
  };

    // If there's no timezone info the data is local time
  if (DF[8] == null) {
    return new Date(DF[0], DF[1], DF[2], DF[3], DF[4], DF[5], DF[6]);
  } else {
      // If Timezone indicator is "Z" or "UT", it's UTC, otherwise it's an offset and needs to be figured out
    if (DF[8] == "Z" || DF[8] == "UT") {
      return new Date(Date.UTC(DF[0], DF[1], DF[2], DF[3], DF[4], DF[5], DF[6]));
    } else {
        // Regex value to split the parts
      var ParsedTZ = new RegExp("^([\+\-])(1[012]|[0]?[0-9])(?::?)([0-5]?[0-9])$").exec(DF[8])
        // Get current Timezone information
      var CurTZ = new Date().getTimezoneOffset();
      var CurTZh = ParsedTZ[1] + ParsedTZ[2] - ((CurTZ >= 0 ? "-" : "+") + Math.floor(Math.abs(CurTZ) / 60))
      var CurTZm = ParsedTZ[1] + ParsedTZ[3] - ((CurTZ >= 0 ? "-" : "+") + (Math.abs(CurTZ) % 60))
        // Return the date
      return new Date(DF[0], DF[1], DF[2], DF[3] - CurTZh, DF[4] - CurTZm, DF[5], DF[6]);
    };
  };
    // If we've reached here we couldn't deal with the input, return null
  return null;

};

  // parseHttpTimeFormat
  // Converts a string formated as a date using RFC 822 specification
Date.parseHttpTimeFormat = function(CurDate) {

    // Check the input parameters
  if ( typeof CurDate != "string" || CurDate == "" ) {
    return null;
  };

  return Date.parseFormat(CurDate, "DDD, D MMM YYYY HH:mm:ss z");

};

  // parseIso8601
  // Attempts to convert ISO8601 input to a date
Date.parseIso8601 = function(CurDate) {

    // Check the input parameters
  if ( typeof CurDate != "string" || CurDate == "" ) {
    return null;
  };
    // Set the fragment expressions
  var S = "[\\-/:.]";
  var Yr = "((?:1[6-9]|[2-9][0-9])[0-9]{2})";
  var Mo = S + "((?:1[012])|(?:0[1-9])|[1-9])";
  var Dy = S + "((?:3[01])|(?:[12][0-9])|(?:0[1-9])|[1-9])";
  var Hr = "(2[0-4]|[01]?[0-9])";
  var Mn = S + "([0-5]?[0-9])";
  var Sd = "(?:" + S + "([0-5]?[0-9])(?:[.,]([0-9]+))?)?";
  var TZ = "(?:(Z)|(?:([\+\-])(1[012]|[0]?[0-9])(?::?([0-5]?[0-9]))?))?";
    // RegEx the input
    // First check: Just date parts (month and day are optional)
    // Second check: Full date plus time (seconds, milliseconds and TimeZone info are optional)
  var TF;
  if ( TF = new RegExp("^" + Yr + "(?:" + Mo + "(?:" + Dy + ")?)?" + "$").exec(CurDate) ) {} else if ( TF = new RegExp("^" + Yr + Mo + Dy + "[Tt ]" + Hr + Mn + Sd + TZ + "$").exec(CurDate) ) {};
    // If the date couldn't be parsed, return null
  if ( !TF ) { return null };
    // Default the Time Fragments if they're not present
  if ( !TF[2] ) { TF[2] = 1 } else { TF[2] = TF[2] - 1 };
  if ( !TF[3] ) { TF[3] = 1 };
  if ( !TF[4] ) { TF[4] = 0 };
  if ( !TF[5] ) { TF[5] = 0 };
  if ( !TF[6] ) { TF[6] = 0 };
  if ( !TF[7] ) { TF[7] = 0 };
  if ( !TF[8] ) { TF[8] = null };
  if ( TF[9] != "-" && TF[9] != "+" ) { TF[9] = null };
  if ( !TF[10] ) { TF[10] = 0 } else { TF[10] = TF[9] + TF[10] };
  if ( !TF[11] ) { TF[11] = 0 } else { TF[11] = TF[9] + TF[11] };
    // If there's no timezone info the data is local time
  if ( !TF[8] && !TF[9] ) {
    return new Date(TF[1], TF[2], TF[3], TF[4], TF[5], TF[6], TF[7]);
  };
    // If the UTC indicator is set the date is UTC
  if ( TF[8] == "Z" ) {
    return new Date(Date.UTC(TF[1], TF[2], TF[3], TF[4], TF[5], TF[6], TF[7]));
  };
    // If the date has a timezone offset
  if ( TF[9] == "-" || TF[9] == "+" ) {
      // Get current Timezone information
    var CurTZ = new Date().getTimezoneOffset();
    var CurTZh = TF[10] - ((CurTZ >= 0 ? "-" : "+") + Math.floor(Math.abs(CurTZ) / 60))
    var CurTZm = TF[11] - ((CurTZ >= 0 ? "-" : "+") + (Math.abs(CurTZ) % 60))
      // Return the date
    return new Date(TF[1], TF[2], TF[3], TF[4] - CurTZh, TF[5] - CurTZm, TF[6], TF[7]);
  };
    // If we've reached here we couldn't deal with the input, return null
  return null;

};

        // getUSDST 
        // Accepts a full (four digit) year and returns an array with two date objects containing the beginning and end of DST in the US.
        // Only functions for years post 1987 and assumes 2007 rules for later years.  Returns "null" for unknown or out of range values.
Date.getUSDST = function(CurYear) {

    // Check input parameters
  if ( typeof CurYear != "number" || CurYear == "" ) {
    return null;
  };

                // Return an empty array if out-of-range 
        if ( CurYear < 1987 ) { return null }; 

                // Determine the last possible (extreme range) dates. 
        if ( CurYear < 2007 ) { 
                var exOn = 38; 
                var exOff = 31; 
        } else { 
                var exOn = 14; 
                var exOff = 38; 
        }; 
                // Create the dates (first pass) 
        var DSTOn = new Date(CurYear, 2, exOn, 2); 
        var DSTOff = new Date(CurYear, 9, exOff, 2); 
                // Set date to previous Sunday 
        DSTOn.setDate(DSTOn.getDate() - DSTOn.getDay()); 
        DSTOff.setDate(DSTOff.getDate() - DSTOff.getDay()); 
        
                // Return the Array 
        return [DSTOn, DSTOff] 

}; 



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* "Date" Object Prototype Extensions - Decision functions */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

  // isWeekday
  // Returns "true" if the date is Monday-Friday, inclusive
Date.prototype.isWeekday = function() {

  if ( this.getDay() != 0 && this.getDay() != 6 ) {
    return true;
  } else {
    return false;
  };

};

  // isLeapYear
  // Returns "true" if the date is contained within a leap year
Date.prototype.isLeapYear = function() {

  var CurYear = this.getFullYear();
  if ( CurYear % 400 == 0 ) {
    return true;
  } else if ( CurYear % 100 == 0 ) {
    return false;
  } else if ( CurYear % 4 == 0 ) {
    return true;
  } else {
    return false;
  };

};

        // isDST 
        // Returns "true" if the date appears to fall within the local area's Daylight Saving Time (or similar scheme), returns false if the date does not (or it appears that the region doesn't observe DST).
Date.prototype.isDST = function() { 

    // Generate test dates
  var Jan1 = new Date(this.getFullYear(), 0);
  var Jul1 = new Date(this.getFullYear(), 6);

    // DST in the Northern hemisphere is "fall back"
  if ( Jan1.getTimezoneOffset() > Jul1.getTimezoneOffset() && this.getTimezoneOffset() != Jan1.getTimezoneOffset() ){
    return true;
  };
    // DST in Southern hemisphere is "leap ahead"
  if ( Jan1.getTimezoneOffset() < Jul1.getTimezoneOffset() && this.getTimezoneOffset() != Jul1.getTimezoneOffset()){
    return true;
  };
    // We're not in DST 
  return false;
};



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* "Date" Object Prototype Extensions - Formatting functions */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

  // dateFormat
  // Formats the date portion of a date object for display
Date.prototype.dateFormat = function(Mask) {

  var FormattedDate = "";
  var MaskChars = "DMY";
  var Ref_MonthFullName = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  var Ref_MonthAbbreviation = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  var Ref_DayFullName = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  var Ref_DayAbbreviation = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    // Convert any supported simple masks into "real" masks
  switch (Mask) {
    case "short":
      Mask = "M/D/YY";
    break;
    case "medium":
      Mask = "MMM D, YYYY";
    break;
    case "long":
      Mask = "MMMM D, YYYY";
    break;
    case "full":
      Mask = "DDDD, MMMM D, YYYY";
    break;
  };

    // Tack a temporary space at the end of the mask to ensure that the last character isn't a mask character
  Mask += " ";

    // Parse the Mask
  var CurChar;
  var MaskPart = "";
  for ( var Cnt = 0; Cnt < Mask.length; Cnt++ ) {
      // Get the character
    CurChar = Mask.charAt(Cnt);
      // Determine if the character is a mask element
    if ( ( MaskChars.indexOf(CurChar) == -1 ) || ( MaskPart != "" && CurChar != MaskPart.charAt(MaskPart.length - 1) ) ) {
        // Determine if we need to parse a MaskPart or not
      if ( MaskPart != "" ) {
          // Convert the mask part to the date value
        switch (MaskPart) {
          case "D":
            FormattedDate += this.getDate();
            break;
          case "DD":
            FormattedDate += ("0" + this.getDate()).slice(-2);
            break;
          case "DDD":
            FormattedDate += Ref_DayAbbreviation[this.getDay()];
            break;
          case "DDDD":
            FormattedDate += Ref_DayFullName[this.getDay()];
            break;
          case "M":
            FormattedDate += this.getMonth() + 1;
            break;
          case "MM":
            FormattedDate += ("0" + (this.getMonth() + 1)).slice(-2);
            break;
          case "MMM":
            FormattedDate += Ref_MonthAbbreviation[this.getMonth()];
            break;
          case "MMMM":
            FormattedDate += Ref_MonthFullName[this.getMonth()];
            break;
          case "YY":
            FormattedDate += ("0" + this.getFullYear()).slice(-2);
            break;
          case "YYYY":
            FormattedDate += ("000" + this.getFullYear()).slice(-4);
            break;
        };
          // Reset the MaskPart to nothing
        MaskPart = "";
      };
        // If the char is a mask char, start a new mask part, otherwise, dump it to the output
      if ( MaskChars.indexOf(CurChar) > -1 ) {
        MaskPart = CurChar;
      } else {
        FormattedDate += CurChar;
      };
    } else {
        // Add the current mask character to the MaskPart
      MaskPart += CurChar;
    };
  };

    // Remove the temporary space from the end of the formatted date
  FormattedDate = FormattedDate.substring(0,FormattedDate.length - 1);

    // Return the formatted date
  return FormattedDate;

};


  // timeFormat
  // Formats the time portion of a Date object for display
Date.prototype.timeFormat = function(Mask) {

  var FormattedTime = "";
  var MaskChars = "hHmsltT";

    // Convert any supported simple masks into "real" masks
  switch (Mask) {
    case "short":
      Mask = "h:mm tt";
    break;
    case "medium":
      Mask = "h:mm:ss tt";
    break;
    case "long":
      Mask = "h:mm:ss.l tt";
    break;
    case "full":
      Mask = "h:mm:ss.l tt";
    break;
  };

    // Tack a temporary space at the end of the mask to ensure that the last character isn't a mask character
  Mask += " ";

    // Parse the Mask
  var CurChar;
  var MaskPart = "";
  for ( var Cnt = 0; Cnt < Mask.length; Cnt++ ) {
      // Get the character
    CurChar = Mask.charAt(Cnt);
      // Determine if the character is a mask element
    if ( ( MaskChars.indexOf(CurChar) == -1 ) || ( MaskPart != "" && CurChar != MaskPart.charAt(MaskPart.length - 1) ) ) {
        // Determine if we need to parse a MaskPart or not
      if ( MaskPart != "" ) {
          // Convert the mask part to the date value
        switch (MaskPart) {
          case "h":
            var CurValue = this.getHours();
            if ( CurValue >  12 ) {
              CurValue = CurValue - 12;
            };
            FormattedTime += CurValue;
            break;
          case "hh":
            var CurValue = this.getHours();
            if ( CurValue >  12 ) {
              CurValue = CurValue - 12;
            };
            FormattedTime += ("0" + CurValue).slice(-2);
            break;
          case "H":
            FormattedTime += ("0" + this.getHours()).slice(-2);
            break;
          case "HH":
            FormattedTime += ("0" + this.getHours()).slice(-2);
            break;
          case "m":
            FormattedTime += this.getMinutes();
            break;
          case "mm":
            FormattedTime += ("0" + this.getMinutes()).slice(-2);
            break;
          case "s":
            FormattedTime += this.getSeconds();
            break;
          case "ss":
            FormattedTime += ("0" + this.getSeconds()).slice(-2);
            break;
          case "l":
            FormattedTime += ("00" + this.getMilliseconds()).slice(-3);
            break;
          case "t":
            if ( this.getHours() > 11 ) {
              FormattedTime += "p";
            } else {
              FormattedTime += "a";
            };
            break;
          case "tt":
            if ( this.getHours() > 11 ) {
              FormattedTime += "pm";
            } else {
              FormattedTime += "am";
            };
            break;
          case "T":
            if ( this.getHours() > 11 ) {
              FormattedTime += "P";
            } else {
              FormattedTime += "A";
            };
            break;
          case "TT":
            if ( this.getHours() > 11 ) {
              FormattedTime += "PM";
            } else {
              FormattedTime += "AM";
            };
            break;
        };
          // Reset the MaskPart to nothing
        MaskPart = "";
      };
        // If the char is a mask char, start a new mask part, otherwise, dump it to the output
      if ( MaskChars.indexOf(CurChar) > -1 ) {
        MaskPart = CurChar;
      } else {
        FormattedTime += CurChar;
      };
    } else {
        // Add the current mask character to the MaskPart
      MaskPart += CurChar;
    };
  };

    // Remove the temporary space from the end of the formatted date
  FormattedTime = FormattedTime.substring(0,FormattedTime.length - 1);

    // Return the formatted date
  return FormattedTime;

};


  // iso8601Format
  // Formats a date using an ISO8601-compliant format
Date.prototype.iso8601Format = function(Style, isUTC) {

    // Set the default
  if ( typeof Style != "string" && typeof Style != "number" ) {
    var Style = "YMDHMSM";
  };

  var FormattedDate = "";
  var AddTZ = false;

  switch (Style) {
    case "Y":
    case 1:
      FormattedDate += this.dateFormat("YYYY");
      break;
    case "YM":
    case 2:
      FormattedDate += this.dateFormat("YYYY-MM");
      break;
    case "YMD":
    case 3:
      FormattedDate += this.dateFormat("YYYY-MM-DD");
      break;
    case "YMDHM":
    case 4:
      FormattedDate += this.dateFormat("YYYY-MM-DD") + "T" + this.timeFormat("HH:mm");
      AddTZ = true;
      break;
    case "YMDHMS":
    case 5:
      FormattedDate += this.dateFormat("YYYY-MM-DD") + "T" + this.timeFormat("HH:mm:ss");
      AddTZ = true;
      break;
    case "YMDHMSM":
    case 6:
      FormattedDate += this.dateFormat("YYYY-MM-DD") + "T" + this.timeFormat("HH:mm:ss.l");
      AddTZ = true;
      break;
  };

  if ( AddTZ ) {
    if ( isUTC ) {
      FormattedDate += "Z";
    } else {
        // Get TimeZone Information
      var TimeZoneOffset = this.getTimezoneOffset();
      var TimeZoneInfo = (TimeZoneOffset >= 0 ? "-" : "+") + ("0" + (Math.floor(Math.abs(TimeZoneOffset) / 60))).slice(-2) + ":" + ("00" + (Math.abs(TimeZoneOffset) % 60)).slice(-2);
      FormattedDate += TimeZoneInfo;
    };
  };

    // Return the date
  return FormattedDate;

};

  // httpTimeFormat
  // Formats a date using the specification in RFC 822-defined format
Date.prototype.httpTimeFormat = function(isUTC) {

  var FormattedDate = "";
  FormattedDate += this.dateFormat("DDD, D MMM YYYY ");
  FormattedDate += this.timeFormat("HH:mm:ss ");

  if ( isUTC ) {
    FormattedDate += "UT";
  } else {
      // Get TimeZone Information
    var TimeZoneOffset = this.getTimezoneOffset();
    var TimeZoneInfo = (TimeZoneOffset >= 0 ? "-" : "+") + ("0" + (Math.floor(Math.abs(TimeZoneOffset) / 60))).slice(-2) + ("00" + (Math.abs(TimeZoneOffset) % 60)).slice(-2);
    FormattedDate += TimeZoneInfo;
  };

    // Return the date
  return FormattedDate;

};



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* "Date" Object Prototype Extensions - Convenience functions */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

  // dayOfYear
  // Returns the day of the year
Date.prototype.dayOfYear = function() {

  var FirstOfYear = new Date(this.getFullYear(), 0, 1);
  return this.diff(FirstOfYear, "days") + 1;

};

  // weekOfYear
  // Returns the week of the year
Date.prototype.weekOfYear = function() {

  var FirstOfYear = new Date(this.getFullYear(), 0, 1);
  return this.diff(FirstOfYear, "weeks") + 1;

};



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* "Date" Object Prototype Extensions - Math functions */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

  // round
  // Rounds a date to the closest specified date part.
Date.prototype.round = function(DatePart, Destructive) {

    // Manage Input Params
  if ( typeof DatePart == "string" ) { DatePart = DatePart.toLowerCase() } else { DatePart = "seconds" };
  if ( typeof Destructive != "boolean" ) { Destructive = false };

    // Set a working/temp date
  var ReturnDate = new Date(this);
  var Ef;

    // Set non-significant values to baseline
  switch (DatePart) {
    case "years":
        // Mid-year is July Second
      var MidYear = new Date(this.getFullYear(), 6, 2, 12);
        // Do the rounding
      if ( this.round("days").getTime() < MidYear.getTime() ) { Ef = "F" } else { Ef = "C" };
      break;
    case "months":
        // Get the Mid-point of the month
      var TempDate = new Date(this);
      TempDate.setDate(32);
      TempDate.setDate(0);
      var MidPoint = Math.round(TempDate.getDate() / 2);
        // Do the rounding
      if ( this.round("days").getDate() < MidPoint ) { Ef = "F" } else { Ef = "C" };
      break;
    case "weeks":
        // Deal with first day of week
      if ( this.floor("weeks").diff(this.round("Days"), "Days") < 4 ) {
        Ef = "F";
      } else {
        Ef = "C";
      };
      break;
    case "days":
    case "businessdays":
      if ( this.getDay() == 6 ) { Ef = "F" } else if ( this.getDay() == 0 ) { Ef = "C" } else if ( this.getHours() < 12 ) { Ef = "F" } else { Ef = "C" };
      break;
    case "hours":
      if ( this.getMinutes() < 30 ) { Ef = "F" } else { Ef = "C" };
      break;
    case "halfhours":
      var M = this.round("Minutes").getMinutes();
      if ( M<15 || (M>29 && M<45) ) { Ef = "F" } else { Ef = "C" };
      break;
    case "quarterhours":
    case "warhols":
      var M = this.round("Minutes").getMinutes();
      if ( M<8 || (M>14 && M<23) || (M>29 && M<38) || (M>44 && M<53) ) { Ef = "F" } else { Ef = "C" };
      break;
    case "minutes":
      if ( this.getSeconds() < 30 ) { Ef = "F" } else { Ef = "C" };
      break;
    case "seconds":
      if ( this.getMilliseconds() < 500 ) { Ef = "F" } else { Ef = "C" };
      break;
    case "milliseconds":
      break;
  };
  
    // Call floor/ceil to finish the job
  if ( Ef == "F" ) {
    ReturnDate = this.floor(DatePart);
  } else if ( Ef == "C") {
    ReturnDate = this.ceil(DatePart);
  };

    // Return
  if ( !Destructive ) {
    return ReturnDate;
  } else {
    this.setTime(ReturnDate.getTime());
    return this;
  };

};

  // ceil
  // Rounds a date upwards to the closest specified date part.
Date.prototype.ceil = function(DatePart, Destructive) {

    // Manage Input Params
  if ( typeof DatePart == "string" ) { DatePart = DatePart.toLowerCase() } else { DatePart = "seconds" };
  if ( typeof Destructive != "boolean" ) { Destructive = false };

    // Set a working/temp date
  var ReturnDate;

    // Set non-significant values to baseline
  switch (DatePart) {
    case "years":
      ReturnDate = new Date( this.getFullYear() + 1, 0, 1);
      break;
    case "months":
      ReturnDate = new Date( this.getFullYear(), this.getMonth() + 1, 1 );
      break;
    case "weeks":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate() );
        // Deal with first day of week
      if ( Date.FirstDayOfWeek <= this.getDay() ) {
        var FirstDayOffset = 7 + (Date.FirstDayOfWeek - this.getDay());
      } else {
        var FirstDayOffset = -this.getDay() + Date.FirstDayOfWeek;
      };
      ReturnDate = ReturnDate.add(FirstDayOffset, "days");
      break;
    case "days":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate() + 1 );
      break;
    case "businessdays":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate() + 1 );
        // If the result is a business day, keep it, otherwise shift it.
      if ( ReturnDate.getDay() == 0 ) {
        ReturnDate = ReturnDate.add(1, "days");
      } else if ( ReturnDate.getDay() == 6 ) {
        ReturnDate = ReturnDate.add(2, "days");
      };
      break;
    case "hours":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours() + 1 );
      break;
    case "halfhours":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours() );
      if ( this.getMinutes() < 30 ) {
        ReturnDate.setMinutes(30);
      } else {
        ReturnDate.setMinutes(60);
      };
      break;
    case "quarterhours":
    case "warhols":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours() );
      if ( this.getMinutes() < 15 ) {
        ReturnDate.setMinutes(15);
      } else if ( this.getMinutes() < 30 ) {
        ReturnDate.setMinutes(30);
      } else if ( this.getMinutes() < 45 ) {
        ReturnDate.setMinutes(45);
      } else {
        ReturnDate.setMinutes(60);
      };
      break;
    case "minutes":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours(), this.getMinutes() + 1 );
      break;
    case "seconds":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours(), this.getMinutes(), this.getSeconds() + 1 );
      break;
    case "milliseconds":
      ReturnDate = new Date( this );
      break;
  };

    // Return
  if ( !Destructive ) {
    return ReturnDate;
  } else {
    this.setTime(ReturnDate.getTime());
    return this;
  };

};

  // floor
  // Rounds a date downward to the closest specified date part.
Date.prototype.floor = function(DatePart, Destructive) {

    // Manage Input Params
  if ( typeof DatePart == "string" ) { DatePart = DatePart.toLowerCase() } else { DatePart = "seconds" };
  if ( typeof Destructive != "boolean" ) { Destructive = false };

    // Set a working/temp date
  var ReturnDate;

    // Set non-significant values to baseline
  switch (DatePart) {
    case "years":
      ReturnDate = new Date( this.getFullYear(), 0, 1 );
      break;
    case "months":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), 1 );
      break;
    case "weeks":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate() );
      ReturnDate = ReturnDate.ceil("weeks").add(-7, "days");
      break;
    case "days":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate() );
      break;
    case "businessdays":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate() );
        // If the result is a business day, keep it, otherwise shift it.
      if ( ReturnDate.getDay() == 0 ) {
        ReturnDate = ReturnDate.add(-2, "days");
      } else if ( ReturnDate.getDay() == 6 ) {
        ReturnDate = ReturnDate.add(-1, "days");
      };
      break;
    case "hours":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours() );
      break;
    case "halfhours":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours() );
      if ( this.getMinutes() < 30 ) {
        ReturnDate.setMinutes(0);
      } else {
        ReturnDate.setMinutes(30);
      };
      break;
    case "quarterhours":
    case "warhols":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours() );
      if ( this.getMinutes() < 15 ) {
        ReturnDate.setMinutes(0);
      } else if ( this.getMinutes() < 30 ) {
        ReturnDate.setMinutes(15);
      } else if ( this.getMinutes() < 45 ) {
        ReturnDate.setMinutes(30);
      } else {
        ReturnDate.setMinutes(45);
      };
      break;
    case "minutes":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours(), this.getMinutes() );
      break;
    case "seconds":
      ReturnDate = new Date( this.getFullYear(), this.getMonth(), this.getDate(), this.getHours(), this.getMinutes(), this.getSeconds() );
      break;
    case "milliseconds":
      ReturnDate = new Date( this );
      break;
  };

    // Return
  if ( !Destructive ) {
    return ReturnDate;
  } else {
    this.setTime(ReturnDate.getTime());
    return this;
  };

};

  // compare
  // Compares two dates (optionally using a specific datepart precision)
Date.prototype.compare = function(CompareDate, DatePart) {

    // Manage Input Params
  if ( !Date.is(CompareDate) ) { CompareDate = new Date() };
  if ( typeof DatePart == "string" ) { DatePart = DatePart.toLowerCase() } else { DatePart = "milliseconds" };

    // Set working/temp vars
  var Date1 = new Date(this);
  var Date2 = new Date(CompareDate);
  var Result;

    // Set the precision by equalizing higher precision elements
  Date1.floor(DatePart);
  Date2.floor(DatePart);

    // Do the comparison
  if ( Date1.getTime() == Date2.getTime() ) {
    Result = 0;
  } else if ( Date1.getTime() < Date2.getTime() ) {
    Result = -1;
  } else {
    Result = 1;
  };

    // Return the result
  return Result;

};

  // add
  // Adds a specified number of a specified date unit to a date
Date.prototype.add = function(Amount, DatePart, Destructive) {

    // Manage Input Params
  if ( typeof Amount == "number" ) { Math.abs(Amount) } else { Amount = 0 };
  if ( typeof DatePart == "string" ) { DatePart = DatePart.toLowerCase() } else { DatePart = "milliseconds" };

  var ReturnDate = new Date(this);

    // Can't add zero date parts
  if ( Amount != 0 ) {
  
      // Do the math
    switch (DatePart) {
        // The following are all unambigously convertable to ms equivalents
      case "milliseconds":
        ReturnDate.setMilliseconds(ReturnDate.getMilliseconds() + Amount);
        break;
      case "seconds":
        ReturnDate.setSeconds(ReturnDate.getSeconds() + Amount);
        break;
      case "minutes":
        ReturnDate.setMinutes(ReturnDate.getMinutes() + Amount);
        break;
      case "quarterhours":
      case "warhols":
        ReturnDate.setMinutes(ReturnDate.getSeconds() + (Amount*15));
        break;
      case "halfhours":
        ReturnDate.setMinutes(ReturnDate.getSeconds() + (Amount*30));
        break;
      case "hours":
        ReturnDate.setHours(ReturnDate.getHours() + Amount);
        break;
      case "days":
        ReturnDate.setDate(ReturnDate.getDate() + Amount);
        break;
      case "weeks":
        ReturnDate.setDate(ReturnDate.getDate() + (Amount*7));
        break;
      case "businessdays":
        ReturnDate.setDate(ReturnDate.getDate() + Amount);
            break;
      case "months":
        ReturnDate.setMonth(ReturnDate.getMonth() + Amount);
        break;
      case "years":
        ReturnDate.setFullYear(ReturnDate.getFullYear() + Amount);
        break;
    };
  };

    // Return the time
  if ( !Destructive ) {
    return ReturnDate;
  } else {
    this.setTime(ReturnDate.getTime());
    return this;
  };

};


  // diff
  // Returns the difference between two dates.
Date.prototype.diff = function(CompareDate, DatePart, CompareMethod, NormalizeDST) {

    // Manage input params and defaults
  if ( !Date.is(CompareDate) ) { CompareDate = new Date() };
  if ( typeof DatePart == "string" ) { DatePart = DatePart.toLowerCase() } else { DatePart = "milliseconds" };
  if ( typeof CompareMethod == "string" ) { CompareMethod = CompareMethod.toLowerCase() } else { CompareMethod = "actual" };
  if ( typeof NormalizeDST != "boolean" ) { NormalizeDST = true };

    // Declare variables
  var Diff, BaseDiff, Date1, Date2, Date1TZO, Date2TZO;

    // Set the dates in order, Date1 previous
  if ( this.getTime() <= CompareDate.getTime() ) {
    Date1 = new Date(this);
    Date2 = new Date(CompareDate);
  } else {
    Date1 = new Date(CompareDate);
    Date2 = new Date(this);
  };

    // Attempt to normalize DST
  if ( NormalizeDST ) {
    Date1TZO = Date1.getTimezoneOffset();
    Date2TZO = Date2.getTimezoneOffset();

    if ( Date1TZO > Date2TZO ) {
      Date2 = Date2.add(Date1TZO - Date2TZO, "Minutes");
    } else
    if ( Date1.getTimezoneOffset() < Date2.getTimezoneOffset() ) {
      Date1 = Date1.add(Date2TZO - Date1TZO, "Minutes");
    };
  };

    // Set the Base Different (in ms)
  BaseDiff = (Date1.getTime() - Date2.getTime());

    // Prepare the two dates
  if ( CompareMethod == "logical" ) {
    Date1.floor(DatePart, true);
    Date2.floor(DatePart, true);
      // Add to address dates on the instant of change
    Date2.add(1, "Milliseconds", true);
  };
  if ( CompareMethod == "complete" ) {
      // Add to address dates on the instant of change
    Date1.add(-1, "Milliseconds", true);
      // Move to the next full date part
    Date1.ceil(DatePart, true);
  };

    // Do the math
    //
    // For simple date parts:
    // "actual" is the difference between ms divided by the appropriate factors.
    // "logical" zeros out the non-significant date parts and does a Diff on the result. 
    // "complete" moves Date1 to the ms before the beginning of the next period, zeros out non-significant date parts, moves Date1 to the beginning of the next period and does a Diff on the result
  switch (DatePart) {

    case "milliseconds":
      Diff = BaseDiff;
      break;
    case "seconds":
    case "minutes":
    case "quarterhours":
    case "warhols":
    case "halfhours":
    case "hours":
    case "days":
    case "weeks":
      if ( CompareMethod == "actual" ) {
        Diff = parseInt( BaseDiff / Date.Factors[DatePart] );
      } else {
        Diff = Date1.diff(Date2, DatePart, "Actual", NormalizeDST);
      };
      break;
    case "businessdays":
        // Set Date2 to the end of a non-business day
      if ( Date2.getDay() == 0 || Date2.getDay() == 6 ) {
          Date2.ceil(DatePart, true);
        };
        // First get the number of days between the dates
      var IntDiff = Date1.diff(Date2, "Days", CompareMethod, NormalizeDST);
        // Count through the days and remove the Saturdays and Sundays
      while ( Date1.getTime() < Date2.getTime() ) {
        if ( Date1.getDay() == 0 || Date1.getDay() == 6 ) {
          --IntDiff;
        };
        Date1 = Date1.add(1, "days");
      };
      Diff = IntDiff;
              break;
    case "months":
      var MonthsCnt = 0;
        // Count up the months
      while ( Date1.getTime() < Date2.getTime() ) {
        Date1.setMonth(Date1.getMonth() + 1);
        MonthsCnt++;
          // Determine if a "full" month has passed, date to date
        if ( Date1.getFullYear() == Date2.getFullYear() && Date1.getMonth() == Date2.getMonth() ) {
          if (  Date1.getDate() > Date2.getDate() ) {
            --MonthsCnt;
          } else {
            break;
          };
        };
      };
      Diff = MonthsCnt;
      break;
    case "years":
      Diff = parseInt(Date1.diff(Date2, "Months", "Actual", NormalizeDST) / 12) ;
      break;
  };

    // Return the time (abs to eliminate negative returns)
  return Math.abs(Diff);

};