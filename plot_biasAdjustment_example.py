from birdy import WPSClient
import birdy
from os.path import basename
import urllib.request


fp_server = 'http://localhost:8093/wps'    # flyingpigeon
fp_i = WPSClient(fp_server, progress=True)
fp = WPSClient(fp_server)

finch_server = 'http://localhost:8092/wps'   # finch
finch_i = WPSClient(url=finch_server, progress=True)
finch = WPSClient(finch_server)


# files to be displayed

tas_obs = '/home/nils/nap_niger/data/bbox/tas_AFR-22_ECMWF-ERAINT_evaluation_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19790101-20161231.nc'
tas_hist = '/home/nils/nap_niger/data/bbox/tas_AFR-22_MOHC-HadGEM2-ES_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051230.nc'
tasAdjust_hist = '/home/nils/nap_niger/data/adjust/tasAdjust_AFR-22_MOHC-HadGEM2-ES_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051230.nc'
tas26Adjust_rcp26 = '/home/nils/nap_niger/data/adjust/tasAdjust_AFR-22_MOHC-HadGEM2-ES_rcp26_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_20060101-20981230.nc'

url_obs = finch.tg_mean(tas=tas_obs, freq='YS').get()[0]
url_hist = finch.tg_mean(tas=tas_hist, freq='YS').get()[0]
url_histAjust = finch.tg_mean(tas=tasAdjust_hist, freq='YS').get()[0]
url_rcp26Ajust = finch.tg_mean(tas=tas26Adjust_rcp26, freq='YS').get()[0]

plot = fp.plot_spaghetti(resource=[url_obs, url_hist, url_histAjust, url_rcp26Ajust], variable=None)

# get the url for the image to be displayed in a web browser
plot.get()[0]
