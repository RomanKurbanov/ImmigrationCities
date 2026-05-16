insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency) values ('professional',(select id from country where name = 'Japan'),0,0,650000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'Japan'),1900000,30,650000+80000,'JPY',1160000);
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'Japan'),3600000,20,1160000+440000,'JPY',1760000);
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'Japan'),6600000,10,1760000+1100000,'JPY',1950000);
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'Japan'),8500000,0,1950000,'JPY',1950000);

insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),0,950000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),1320000,880000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),3360000,680000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),4890000,630000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),6550000,580000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),23500000,480000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),24000000,320000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),24500000,160000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Japan'),25000000,0,'JPY');

insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('local',(select id from country where name = 'Japan'),0,430000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('local',(select id from country where name = 'Japan'),24000000,290000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('local',(select id from country where name = 'Japan'),24500000,150000,'JPY');
insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('local',(select id from country where name = 'Japan'),25000000,0,'JPY');

insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'South Korea'),0,70,0,'KRW',3500000);
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'South Korea'),5000000,40,3500000,'KRW',7500000);
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'South Korea'),15000000,15,7500000,'KRW',12000000);
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'South Korea'),45000000,5,12000000,'KRW',14750000);
insert into deduction (deduction_type, country_id, deduction_from, deduction_rate, fixed_deduction, currency,deduction_limit) values ('professional',(select id from country where name = 'South Korea'),100000000,2,14750000,'KRW',20000000);

insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'South Korea'),0,1500000,'KRW');

insert into deduction (deduction_type, country_id, deduction_from, fixed_deduction, currency) values ('personal',(select id from country where name = 'Denmark'),0,54100,'DKK');