-- soru: miuul.gezinomi isminde bir tablo oluşturunuz
create schema miuul;
create table miuul.gezinomi( saleid int, saledate timestamp , checkindate timestamp, price float, conceptname text, salecityname text, cinday text, salecheckindaydiff int, seasons text );

-- Görev 1: Aşağıdaki Soruları Yanıt layınız
	-- soru: i̇lk 10 satırını gözlemleyiniz
	select	* from	miuul.gezinomi limit 10;
 	-- soru: kaç unique şehir vardır? frekansları nedir?
 	select	count(distinct (salecityname)) from	miuul.gezinomi;
	select	salecityname,	count(*) from miuul.gezinomi group by salecityname order by count desc;
	-- soru: kaç unique concept vardır? hangi concept'dan kaçar tane satış gerçekleşmiş? 
	select	count(distinct (conceptname)) from	miuul.gezinomi;
	select	conceptname,	count(*) from	miuul.gezinomi group by conceptname order by count desc;
 	-- soru: şehirlere göre satışlardan toplam ne kadar kazanılmış? 
 	select	salecityname,	sum(price) as total_price from	miuul.gezinomi group by	salecityname;
 	-- soru: concept türlerine göre göre ne kadar kazanılmış? 
 	select	conceptname,	sum(price) as total_price from	miuul.gezinomi group by	conceptname;
 	-- soru: şehirlere göre price ortalamaları nedir?
 	select	salecityname,	avg(price) as mean_price from	miuul.gezinomi group by salecityname;
 	-- soru: concept göre price ortalamaları nedir?
 	select	conceptname,	avg(price) as mean_price from	miuul.gezinomi group by	conceptname;
 	-- soru: şehir-concept kırılımında price ortalamaları nedir?
 	select	salecityname,	conceptname,	avg(price) as mean_price from	miuul.gezinomi group by	salecityname,	conceptname;

-- Görev 2: SaleCheckInDayDiff değişkenini kategorik bir değişkene çeviriniz. 
--  
create table miuul.sales as
select
	g.*,
	case
		when salecheckindaydiff < 7 then 'last minuters'
		when salecheckindaydiff >= 7
		and salecheckindaydiff < 30 then 'potential planners'
		when salecheckindaydiff >= 7
		and salecheckindaydiff < 30 then 'planners'
		else 'early bookers'
	end as eb_score
from
	miuul.gezinomi as g;

select * from miuul.sales;

-- Görev 3: Aşağıdaki sorgulamaları yapınız.
-- Şehir-Konsept-EB_Score 
-- Şehir-Konsept-Sezon 
-- Şehir-Konsept-CInDay 
-- kırılımlarında ortalama ödenen ücret ve yapılan işlem sayısı cinsinden inceleyiniz.

-- Şehir-Konsept-EB_Score 
select
	salecityname,
	conceptname,
	eb_score,
	avg(price) as mean_price,
	count(*) as count
from
	miuul.sales 
group by
	salecityname,
	conceptname,
	eb_score;

-- Şehir-Konsept-Sezon 
select
	salecityname,
	conceptname,
	seasons,
	avg(price) as mean_price,
	count(*) as count
from
	miuul.sales 
group by
	salecityname,
	conceptname,
	seasons;

-- Şehir-Konsept-CInDay 
select
	salecityname,
	conceptname,
	cinday,
	avg(price) as mean_price,
	count(*) as count
from
	miuul.sales 
group by
	salecityname,
	conceptname,
	cinday;

-- Görev 4: city-concept-season kırılımın çıktısını price'a göre sıralayınız. 
-- çıktıyı miuul.sales_ccs olarak kaydediniz. 
create table miuul.sales_ccs as
select
	salecityname,
	conceptname,
	seasons,
	avg(price) as mean_price,
	count(*) as count
from
	miuul.sales 
group by
	salecityname,
	conceptname,
	seasons
order by
	mean_price desc;

select 	* from	miuul.sales_ccs limit 10 ;


-- Görev 5: yeni level based satışları tanımlayınız. level_base_sales adında yeni tablo olarak kaydediniz.
create table miuul.level_base_sales as
select
	ad.*,
	upper( concat( ad.salecityname, '_', ad.conceptname, '_', ad.seasons ) ) as sales_level_based
from
	miuul.sales_ccs ad;

select 	* from	miuul.level_base_sales limit 10 ;

-- görev 6: personaları segmentlere ayırınız.
-- Yeni personaları PRICE’a göre 4 segmente ayırınız.
-- Segmentleri SEGMENT isimlendirmesi ile değişken oluşturunuz. miuul.segment adında yeni tablo olarak kaydediniz.
create table miuul.segment as
select
	lbs.*,
	case
		when mean_price <= 39.48 then 'd'
		when mean_price > 39.48
		and mean_price <= 54.14 then 'c'
		when mean_price > 54.14
		and mean_price <= 64.92 then 'b'
		else 'a'
	end as segment
from
	miuul.level_base_sales lbs ;

-- Segmentleri betimleyiniz (Segmentlere göre group by yapıp price mean, max, sum’larını alınız).
select
	s.segment,
	avg(s.mean_price) as mean,
	max(s.mean_price) as _max,
	sum(s.mean_price) as _sum
from
	miuul.segment s
group by
	segment 
	
	
-- Görev 7: Yeni satış taleplerini sınıflandırıp, ne kadar gelir getirebileceklerini tahmin ediniz.
-- Antalya’da herşey dahil ve yüksek sezonda tatil yapmak isteyen bir kişinin ortalama ne kadar gelir kazandırması beklenir?
select	* from	miuul.segment s
where sales_level_based = 'ANTALYA_HERŞEY DAHIL_HIGH'

-- Girne’de yarım pansiyon bir otele düşük sezonda giden bir tatilci hangi segmentte yer alacaktır?
select	* from	miuul.segment s
where sales_level_based like 'GIRNE_YARIM%'






