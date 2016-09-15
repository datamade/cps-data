include config.mk enrollment.mk

VPATH = ./raw

.PHONY : cps_school_data
cps_school_data :
	wget -P raw/ -e robots=off -r -l 1 -nd -N -A xls,xlsx -H http://cps.edu/SchoolData/Pages/SchoolData.aspx

%.csv : %.xls
	in2csv $< > $@

act_schools_2001_to_2015.csv : act_schools_2001_to_2015_final.csv
	tail -n +2 $< > $@

cps_act : act_schools_2001_to_2015.csv
	$(create_relation_and) "CREATE TABLE $@ (cps_id INT, \
                                                 category TEXT, \
                                                 year INT, \
                                                 reading FLOAT, \
                                                 math FLOAT, \
                                                 science FLOAT, \
                                                 english FLOAT, \
                                                 composite FLOAT, \
                                                 reading_total FLOAT, \
                                                 math_total FLOAT, \
                                                 science_total FLOAT, \
                                                 english_total FLOAT, \
                                                 composite_total FLOAT)" && \
	csvcut -C 1,3,4,6 $< | psql -d $(PG_DB) -c "COPY $@ FROM STDIN WITH CSV HEADER")


cps_campus : CPS_Schools_2013-2014_Academic_Year.csv
	$(create_relation_and) "CREATE TABLE $@ \
                                (cps_id INT, short_name TEXT, full_name TEXT, \
                                 governance TEXT)" \
	&& csvcut -c "SchoolID","SchoolName","FullName","Governance" $< | \
           psql -d $(PG_DB) -c "COPY $@ FROM STDIN WITH CSV HEADER")
