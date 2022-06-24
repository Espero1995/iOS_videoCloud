/***************************************************************************
 *   Copyright (C) 2014 by Yexr   *
 *   yexr@vveye.com   *
 ***************************************************************************/
#ifndef _LIB_T2U_H_
#define _LIB_T2U_H_

#ifdef WIN32
typedef __int64			int64_t;
#define T2UAPI			__stdcall
#else
#define T2UAPI	
#include <stdint.h>
#endif

#ifdef __cplusplus
extern "C"
{
#endif

typedef struct _T2U_CALLBACK
{
	void (T2UAPI *OnConnect)(		/* P2P连接成功*/
				unsigned short local_port,					/* 本地代理端口号*/
				int usetime								/* 建立P2P连接所用时间（毫秒）*/
	);
	
	void (T2UAPI *OnDisconnect)(		/*P2P连接失败或断开*/
		unsigned short local_port,							/* 本地代理端口号*/
		int ret											/* 断开原因
															-2:	P2P连接失败
															-3:  P2P连接中断
															-4:  对方离线
															-5:  设备有密码，密码认证失败
														*/
	);
}T2uCallBack,*PT2uCallBack;

//速率统计
typedef	struct _T2U_NET_RATE
{								
	int64_t				total_recv;			//总接收字节
	int64_t				total_send;			//总发送字节

	float					cur_recv_rate;		//当前接收速率KB/s
	float					cur_send_rate;		//当前发送速率KB/s
	float					cur_rate;			//当前总速率 KB/s

	float					avg_recv_rate;		//平均接收速率KB/s
	float					avg_send_rate;		//平均发送速率KB/s
	float					avg_rate;			//平均总速率KB/s

	int					time_sec;			//统计时长,秒
}T2uNetRate,*PT2uNetRate;

//连接状态
typedef struct _T2U_NET_STAT
{
	char					ip[20];				//对方IP
	int					port;				//对方端口
	int					proxy;				//是否通过代理
	float					lost_rate;			//丢包率
	int					bandwidth;			//估算最大上行带宽KB/s
	int					remote_nattype;		//对方NAT类型
	int					local_nattype;		//本机NAT类型
	char					ip6[40];				//对方IPV6地址
	int					remote_version;		//对方版本号
}T2uNetStat,*PT2uNetStat;

/*
初始化
*/
void	T2UAPI	t2u_init(const char* svraddr,unsigned short svrport,const char* svrkey);

/*
设置回调函数
*/
void	T2UAPI	t2u_set_callback(PT2uCallBack callback);

/*
设置P2P端口范围
min_port:	最小端口号
max_port:	最大端口号
*/
void	T2UAPI	t2u_set_port_range(unsigned short min_port,unsigned short max_port);

/*
添加映射端口

uuid: 远端设备UUID

remote_port:	远端设备端口
local_port:	映射到本地的端口，0表示使用随机端口

返回值:	
	>0:  映射到本地的端口
	-1:  映射失败，端口被占用
*/

int		T2UAPI	t2u_add_port(const char* uuid,unsigned short remote_port,unsigned short local_port);

int		T2UAPI	t2u_add_port_ex(const char* uuid,const char* remote_ip,unsigned short remote_port,unsigned short local_port);

int		T2UAPI	t2u_add_port_v3(const char* uuid,const char* passwd,const char* remote_ip,unsigned short remote_port,unsigned short local_port);

/*
删除映射端口
*/
void	T2UAPI	t2u_del_port(unsigned short port);

/*
查询端口状态

返回值:
1:		已连通
0:		未连通
-1:		不存在
-2:		P2P连接失败，等待30秒后自动重连
-3:		P2P连接中断，等待30秒后自动重连
-4:		对方离线，等待30秒后自动重连
-5:		设备有密码，密码认证失败
*/
int		T2UAPI	t2u_port_status(unsigned short port,PT2uNetStat pStat);


/*
查询速率统计

port:	要查询的端口号，0表示统计全局速率
pRate:	保存数据的速率结构指针

返回值:
		0:	成功
		-1:	端口不存在
*/
int		T2UAPI	t2u_get_rate(unsigned short port,PT2uNetRate pRate);

int		T2UAPI	t2u_add_udp_port(const char* uuid,unsigned short remote_port,unsigned short local_port);
int		T2UAPI	t2u_add_udp_port_ex(const char* uuid,const char* remote_ip,unsigned short remote_port,unsigned short local_port);
int		T2UAPI	t2u_add_udp_port_v3(const char* uuid,const char* passwd,const char* remote_ip,unsigned short remote_port,unsigned short local_port);
void	T2UAPI	t2u_del_udp_port(unsigned short port);
int		T2UAPI	t2u_udp_port_status(unsigned short port,PT2uNetStat pStat);
int		T2UAPI	t2u_get_udp_rate(unsigned short port,PT2uNetRate pRate);


/*
查询设备状态

返回值:
		1:	设备在线
		0:	设备不在线
		-1:	查询失败
*/
int		T2UAPI	t2u_query(const char* uuid);


/*
查询设备状态和附加参数

buff:			保存设备参数的缓存地址
buffsize:		缓存大小，不超过1024字节
ipaddr:		保存设备公网IP的缓存地址
ipsize:		缓存大小

返回值:
		1:	设备在线
		0:	设备不在线
		-1:	查询失败
*/
int		T2UAPI	t2u_query_ex(const char * uuid,char* buff,int buffsize,char* ipaddr,int ipsize);


/*
搜索发现本地内网的设备
搜索结果以文本方式输出，每行一条记录，格式为: uuid=xxxx,ip=x.x.x.x

buff:			输出结果的缓存地址
buffsize:		缓存大小

返回值 :  
		>=0		发现的设备数
		-1		失败
*/
int		T2UAPI	t2u_search(char* buff,int buffsize);

/*
通过代理网关查询对方所在内网的DVR设备
查询结果以文本方式输出，每行一条记录，
格式为: 厂家代码|DVR序列号|通道数|IP|端口

参数
uuid:		代理网关的UUID
outbuff:		输出文本结果的缓存
buffsize:		缓存大小

返回值:
		1:		查询成功，有DVR 设备
		0:		查询成功，但无设备
		-1:		连接失败
		-2:		查询失败
		-3:		查询超时，对方无响应
*/
int		T2UAPI	t2u_search_dvr(const char* uuid,char* outbuff,int buffsize);

/*
查询状态

返回值:
1:		与服务器连接，状态正常
0:		未连接服务器
-1:		SDK未初始化
-2:		密钥无效
*/
int		T2UAPI	t2u_status();

/*
退出并释放资源
*/
void	T2UAPI	t2u_exit();

#ifdef __cplusplus
}
#endif

#endif


