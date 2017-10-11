# cron to run schedule

# */10 05-22 * * 1,2,3,4,5,6,0 /home/tatadm/bin/fmsserv_ping.ksh


 # ┌───────────── min (0 - 59)
 # │ ┌────────────── hour (0 - 23)
 # │ │ ┌─────────────── day of month (1 - 31)
 # │ │ │ ┌──────────────── month (1 - 12)
 # │ │ │ │ ┌───────────────── day of week (0 - 6) (0 to 6 are Sunday to
 # │ │ │ │ │                  Saturday, or use names; 7 is also Sunday)
 # │ │ │ │ │
 # │ │ │ │ │
 # * * * * *  command to execute

source=$1
val=$2

awk -v in_source="$1" -v in_val="$2" ' 

function num_to_text(source,val)
{
   # return val;
   if (source == "dow") {
      if (val == 0) return "Sun"
      else if (val == 1) return "Mon"
      else if (val == 2) return "Tue"
      else if (val == 3) return "Wed"
      else if (val == 4) return "Thu"
      else if (val == 5) return "Fri"
      else if (val == 6) return "Sat"
      else if (val == 7) return "Sun"
   }
   if (source == "month") {
      if (val == 1) return "Jan"
      else if (val == 2) return "Feb"
      else if (val == 3) return "Mar"
      else if (val == 4) return "Apr"
      else if (val == 5) return "May"
      else if (val == 6) return "Jun"
      else if (val == 7) return "Jul"
      else if (val == 8) return "Aug"
      else if (val == 9) return "Sep"
      else if (val == 10) return "Oct"
      else if (val == 11) return "Nov"
      else if (val == 12) return "Dec"
   }
   else 
      return val;


}
function split_time(source,val,arrayname)
{
   for (elem in arrayname) delete arrayname[elem]

   if (source=="min") {
      min=0; max=60
   }
   else if (source=="hour") {
      min=0; max=24
   }
   else if (source=="dom") {
      min=1; max=31
   }
   else if (source=="month") {
      min=1; max=13
   }
   else if (source=="dow") {
      min=0; max=7
   }
   else {
      return
   }

   everyx=0

   for (x=min; x < max; x++) {

      if (val == x) {
         arrayname[x]=x
      }

      else if (substr(val,1,1) == "*") {
         
         if (substr(val,2,1) == "/") {
            
            everyx = substr(val,3)
         
            if (everyx > 0) {
               if (x % everyx != 0) continue
            }
         }
         
         arrayname[x]=x
         
      }

      # between range
      else if (match(val,"-") >= 1) {

         split(val,arr_range,"-")

         # loop through between start / end range of values:
         for (i = arr_range[1]+0; i <= arr_range[2]+0; i++) {
            
            if (x == i) {
               # print "DEBUG "x

               arrayname[x]=x
            }
         }
         
      }

      # comma separated
      else if (match(val,",") >= 1) {
      
         split(val,arr_list,",")
         
         for (i in arr_list) {

            if (x == arr_list[i]) {
               arrayname[x]=x
            }

            delete arr_list[i]
         }
      }
   }

} # end split_time

{

   # print "DEBUG: "$0

   command=""

   min=$1
   hour=$2
   dom=$3
   month=$4
   dow=$5

   for (i=6;i<=NF;i++) {
      command=command " " $i
   }

startmon=10
endmon=10
startdow=0
enddow=0
starthr=18
endhr=22
startdom=0
enddom=0

   split_time("min",min,arr_everymin)
   split_time("hour",hour,arr_everyhour)
   split_time("dom",dom,arr_everydom)
   split_time("month",month,arr_everymonth)
   split_time("dow",dow,arr_everydow)

   for (w in arr_everydow) {

         if (arr_everydow[w] < startdow || arr_everydow[w] > enddow)
            continue

      for (o in arr_everymonth) {

         if ( startmon >0 || endmon > 0) {
            if (arr_everymonth[o] < startmon || arr_everymonth[o] > endmon)
               continue
         }

         for (d in arr_everydom) {
         
            if ( startdom > 0 ||  enddom > 0) {
               if (arr_everydom[d] < startdom || arr_everydom[d] > enddom)
                  continue
            }
       
            for (h in arr_everyhour) {

               if ( starthr > 0 ||  endhr > 0) {
                  if (arr_everyhour[h] < starthr || arr_everyhour[h] > endhr)
                     continue
               }

               for (m in arr_everymin) {


                  printf "%s %d %d %s %s %s\n", 
                     arr_everymin[m],
                     arr_everyhour[h], 
                     arr_everydom[d], 
                     num_to_text("month",arr_everymonth[o]), 
                     num_to_text("dow",arr_everydow[w]), 
                     command
                  # printf "%s %s %s %s %s %s\n", min, hour, dom, month, dow, command
               
               }
               
            }
         }
      }
   }
      

} ' appjob.cron