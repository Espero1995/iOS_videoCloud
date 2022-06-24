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
	void (T2UAPI *OnConnect)(		/* P2P���ӳɹ�*/
				unsigned short local_port,					/* ���ش���˿ں�*/
				int usetime								/* ����P2P��������ʱ�䣨���룩*/
	);
	
	void (T2UAPI *OnDisconnect)(		/*P2P����ʧ�ܻ�Ͽ�*/
		unsigned short local_port,							/* ���ش���˿ں�*/
		int ret											/* �Ͽ�ԭ��
															-2:	P2P����ʧ��
															-3:  P2P�����ж�
															-4:  �Է�����
															-5:  �豸�����룬������֤ʧ��
														*/
	);
}T2uCallBack,*PT2uCallBack;

//����ͳ��
typedef	struct _T2U_NET_RATE
{								
	int64_t				total_recv;			//�ܽ����ֽ�
	int64_t				total_send;			//�ܷ����ֽ�

	float					cur_recv_rate;		//��ǰ��������KB/s
	float					cur_send_rate;		//��ǰ��������KB/s
	float					cur_rate;			//��ǰ������ KB/s

	float					avg_recv_rate;		//ƽ����������KB/s
	float					avg_send_rate;		//ƽ����������KB/s
	float					avg_rate;			//ƽ��������KB/s

	int					time_sec;			//ͳ��ʱ��,��
}T2uNetRate,*PT2uNetRate;

//����״̬
typedef struct _T2U_NET_STAT
{
	char					ip[20];				//�Է�IP
	int					port;				//�Է��˿�
	int					proxy;				//�Ƿ�ͨ������
	float					lost_rate;			//������
	int					bandwidth;			//����������д���KB/s
	int					remote_nattype;		//�Է�NAT����
	int					local_nattype;		//����NAT����
	char					ip6[40];				//�Է�IPV6��ַ
	int					remote_version;		//�Է��汾��
}T2uNetStat,*PT2uNetStat;

/*
��ʼ��
*/
void	T2UAPI	t2u_init(const char* svraddr,unsigned short svrport,const char* svrkey);

/*
���ûص�����
*/
void	T2UAPI	t2u_set_callback(PT2uCallBack callback);

/*
����P2P�˿ڷ�Χ
min_port:	��С�˿ں�
max_port:	���˿ں�
*/
void	T2UAPI	t2u_set_port_range(unsigned short min_port,unsigned short max_port);

/*
���ӳ��˿�

uuid: Զ���豸UUID

remote_port:	Զ���豸�˿�
local_port:	ӳ�䵽���صĶ˿ڣ�0��ʾʹ������˿�

����ֵ:	
	>0:  ӳ�䵽���صĶ˿�
	-1:  ӳ��ʧ�ܣ��˿ڱ�ռ��
*/

int		T2UAPI	t2u_add_port(const char* uuid,unsigned short remote_port,unsigned short local_port);

int		T2UAPI	t2u_add_port_ex(const char* uuid,const char* remote_ip,unsigned short remote_port,unsigned short local_port);

int		T2UAPI	t2u_add_port_v3(const char* uuid,const char* passwd,const char* remote_ip,unsigned short remote_port,unsigned short local_port);

/*
ɾ��ӳ��˿�
*/
void	T2UAPI	t2u_del_port(unsigned short port);

/*
��ѯ�˿�״̬

����ֵ:
1:		����ͨ
0:		δ��ͨ
-1:		������
-2:		P2P����ʧ�ܣ��ȴ�30����Զ�����
-3:		P2P�����жϣ��ȴ�30����Զ�����
-4:		�Է����ߣ��ȴ�30����Զ�����
-5:		�豸�����룬������֤ʧ��
*/
int		T2UAPI	t2u_port_status(unsigned short port,PT2uNetStat pStat);


/*
��ѯ����ͳ��

port:	Ҫ��ѯ�Ķ˿ںţ�0��ʾͳ��ȫ������
pRate:	�������ݵ����ʽṹָ��

����ֵ:
		0:	�ɹ�
		-1:	�˿ڲ�����
*/
int		T2UAPI	t2u_get_rate(unsigned short port,PT2uNetRate pRate);

int		T2UAPI	t2u_add_udp_port(const char* uuid,unsigned short remote_port,unsigned short local_port);
int		T2UAPI	t2u_add_udp_port_ex(const char* uuid,const char* remote_ip,unsigned short remote_port,unsigned short local_port);
int		T2UAPI	t2u_add_udp_port_v3(const char* uuid,const char* passwd,const char* remote_ip,unsigned short remote_port,unsigned short local_port);
void	T2UAPI	t2u_del_udp_port(unsigned short port);
int		T2UAPI	t2u_udp_port_status(unsigned short port,PT2uNetStat pStat);
int		T2UAPI	t2u_get_udp_rate(unsigned short port,PT2uNetRate pRate);


/*
��ѯ�豸״̬

����ֵ:
		1:	�豸����
		0:	�豸������
		-1:	��ѯʧ��
*/
int		T2UAPI	t2u_query(const char* uuid);


/*
��ѯ�豸״̬�͸��Ӳ���

buff:			�����豸�����Ļ����ַ
buffsize:		�����С��������1024�ֽ�
ipaddr:		�����豸����IP�Ļ����ַ
ipsize:		�����С

����ֵ:
		1:	�豸����
		0:	�豸������
		-1:	��ѯʧ��
*/
int		T2UAPI	t2u_query_ex(const char * uuid,char* buff,int buffsize,char* ipaddr,int ipsize);


/*
�������ֱ����������豸
����������ı���ʽ�����ÿ��һ����¼����ʽΪ: uuid=xxxx,ip=x.x.x.x

buff:			�������Ļ����ַ
buffsize:		�����С

����ֵ :  
		>=0		���ֵ��豸��
		-1		ʧ��
*/
int		T2UAPI	t2u_search(char* buff,int buffsize);

/*
ͨ���������ز�ѯ�Է�����������DVR�豸
��ѯ������ı���ʽ�����ÿ��һ����¼��
��ʽΪ: ���Ҵ���|DVR���к�|ͨ����|IP|�˿�

����
uuid:		�������ص�UUID
outbuff:		����ı�����Ļ���
buffsize:		�����С

����ֵ:
		1:		��ѯ�ɹ�����DVR �豸
		0:		��ѯ�ɹ��������豸
		-1:		����ʧ��
		-2:		��ѯʧ��
		-3:		��ѯ��ʱ���Է�����Ӧ
*/
int		T2UAPI	t2u_search_dvr(const char* uuid,char* outbuff,int buffsize);

/*
��ѯ״̬

����ֵ:
1:		����������ӣ�״̬����
0:		δ���ӷ�����
-1:		SDKδ��ʼ��
-2:		��Կ��Ч
*/
int		T2UAPI	t2u_status();

/*
�˳����ͷ���Դ
*/
void	T2UAPI	t2u_exit();

#ifdef __cplusplus
}
#endif

#endif


