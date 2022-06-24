#ifndef _SADP_H_
#define _SADP_H_


#if defined _WIN32 || defined _WIN64
#define CSADP_API  extern "C"__declspec(dllimport)
#elif defined __linux__ || defined __APPLE__
#define CSADP_API  extern "C"
#endif

#if defined _WIN32 || defined _WIN64
#define CALLBACK __stdcall
#elif defined __linux__ || defined __APPLE__
#define CALLBACK  
#endif

#define     BOOLNew int

//��Ϣ����������
#define SADP_ADD		  1			//����һ�豸
#define SADP_UPDATE		  2			//�����豸
#define SADP_DEC		  3			//�豸����
#define SADP_RESTART	  4			//�豸��������
#define SADP_UPDATEFAIL	  5			//�豸����ʧ��

//�ⲿ������
#define SADP_GET_DEVICE_CODE   1			//��ȡ�豸�룬��Ӧ�ṹ��SADP_SAFE_CODE
#define SADP_GET_ENCRYPT_STRING   2			//��ȡ���ܴ�����Ӧ�ṹ��SADP_ENCRYPT_STRING

#define SADP_GET_DEVICE_TYPE_UNLOCK_CODE    3   //��ȡ�豸���ͽ��룬��Ӧ�Ľṹ��SADP_TYPE_UNLOCK_CODE
#define SADP_SET_DEVICE_CUSTOM_TYPE         4   //�����豸�Զ����ͺţ���Ӧ�Ľṹ��SADP_CUSTOM_DEVICE_TYPE

#define SADP_GET_GUID                       5   //��ȡGUID
#define SADP_GET_SECURITY_QUESTION          6   //��ȡ��ȫ����
#define SADP_SET_SECURITY_QUESTION          7   //���ð�ȫ����

#define SADP_SET_HCPLATFORM_STATUS          8   //����HCPLATFORM״̬
#define SADP_SET_VERIFICATION_CODE          9   //������֤�루��֤������өʯ���롢Ԥ�������Ƶ�Ψһ���룩

#define MAX_DEVICE_CODE     128  //�豸�����볤�ȣ��ݶ����128
#define MAX_EXCHANGE_CODE   256  //�����볤��
#define MAX_PASS_LEN           16  //�豸������볤��
#define MAX_FILE_PATH_LEN      260 //�ļ����·������
#define MAX_ENCRYPT_CODE     256  //�豸��������ܺ󳤶�

#define MAX_UNLOCK_CODE_RANDOM_LEN  256   // ����������
#define MAX_UNLOCK_CODE_KEY         256   // �����Կ

#define MAX_GUID_LEN           128 //GUID����
#define MAX_QUESTION_LIST_LEN  32  //��������б����
#define MAX_ANSWER_LEN         256 //���𰸳���
#define SADP_MAX_VERIFICATION_CODE_LEN         12 //�����֤�볤��

// ������
#define SADP_ERROR_BASE					2000
#define SADP_NOERROR 					0					  // û�д���
#define SADP_ALLOC_RESOURCE_ERROR		(SADP_ERROR_BASE+1)   // ��Դ�������
#define SADP_NOT_START_ERROR			(SADP_ERROR_BASE+2)   // SADPδ����
#define SADP_NO_ADAPTER_ERROR			(SADP_ERROR_BASE+3)   // ������
#define SADP_GET_ADAPTER_FAIL_ERROR		(SADP_ERROR_BASE+4)   // ��ȡ������Ϣʧ��
#define SADP_PARAMETER_ERROR			(SADP_ERROR_BASE+5)   // ��������
#define SADP_OPEN_ADAPTER_FAIL_ERROR	(SADP_ERROR_BASE+6)   // ������ʧ��
#define SADP_SEND_PACKET_FAIL_ERROR		(SADP_ERROR_BASE+7)   // ��������ʧ��
#define SADP_SYSTEM_CALL_ERROR			(SADP_ERROR_BASE+8)   // ϵͳ�ӿڵ���ʧ��
#define SADP_DEVICE_DENY		        (SADP_ERROR_BASE+9)   // �豸�ܾ�����
#define SADP_NPF_INSTALL_ERROR			(SADP_ERROR_BASE+10)  // ��װNPF����ʧ��
#define SADP_TIMEOUT					(SADP_ERROR_BASE+11)  // �豸��ʱ
#define SADP_CREATE_SOCKET_ERROR		(SADP_ERROR_BASE+12)  // ����socketʧ��
#define SADP_BIND_SOCKET_ERROR			(SADP_ERROR_BASE+13)  // ��socketʧ��
#define SADP_JOIN_MULTI_CAST_ERROR		(SADP_ERROR_BASE+14)  // ����ಥ��ʧ��
#define SADP_NETWORK_SEND_ERROR			(SADP_ERROR_BASE+15)  // ���ͳ���
#define SADP_NETWORK_RECV_ERROR			(SADP_ERROR_BASE+16)  // ���ճ���
#define SADP_XML_PARSE_ERROR			(SADP_ERROR_BASE+17)  // �ಥXML��������
#define SADP_LOCKED						(SADP_ERROR_BASE+18)  // �豸����
#define SADP_NOT_ACTIVATED              (SADP_ERROR_BASE+19)  // �豸δ����
#define SADP_RISK_PASSWORD              (SADP_ERROR_BASE+20)  // ���ոߵ�����
#define SADP_HAS_ACTIVATED              (SADP_ERROR_BASE+21)  // �豸�Ѽ���
#define SADP_EMPTY_ENCRYPT_STRING       (SADP_ERROR_BASE+22)  // ���ܴ�Ϊ��
#define SADP_EXPORT_FILE_OVERDUE        (SADP_ERROR_BASE+23)  // �����ļ�����
#define SADP_PASSWORD_ERROR             (SADP_ERROR_BASE+24)  // �������
#define SADP_LONG_SECURITY_ANSWER       (SADP_ERROR_BASE+25)  // ��ȫ�����̫��
#define SADP_INVALID_GUID               (SADP_ERROR_BASE+26)  // ��Ч��GUID
#define SADP_ANSWER_ERROR               (SADP_ERROR_BASE+27)  // �𰸴���
#define SADP_QUESTION_NUM_ERR           (SADP_ERROR_BASE+28)  // ��ȫ����������ô���
#define SADP_LOAD_WPCAP_FAIL            (SADP_ERROR_BASE+30)  // ����Wpcapʧ��
#define SADP_ILLEGAL_VERIFICATION_CODE     (SADP_ERROR_BASE+33)  // �Ƿ���֤��


//SADP�豸���˹�������
//��λ��ʾ��Ϊ1��ʾ���ˣ�0��ʾ������;
//bit 1:�Ƿ����өʯ;bit 2:�Ƿ����OEM;
#define SADP_DISPLAY_ALL           0            //��ʾ�����豸
#define SADP_FILTER_EZVIZ          0x01         //����өʯ�豸
#define SADP_FILTER_OEM            0x02         //����OEM�豸
#define SADP_FILTER_EZVIZ_OEM      0x03         //ͬʱ����өʯ��OEM�豸
#define SADP_ONLY_DISPLAY_OEM      0xfffffffd   //����ʾOEM�豸,��Ӧ�ṹ��SADP_DISPLAY_OEM_CFG
#define SADP_ONLY_DISPLAY_EZVIZ    0xfffffffe   //����ʾөʯ�豸
// �ṹ��
typedef struct tagSADP_DEVICE_INFO
{
	char			szSeries[12];
	char			szSerialNO[48];
	char			szMAC[20];
	char			szIPv4Address[16];
	char			szIPv4SubnetMask[16];
	unsigned int	dwDeviceType;
	unsigned int	dwPort;
	unsigned int	dwNumberOfEncoders; 
	unsigned int	dwNumberOfHardDisk;
	char			szDeviceSoftwareVersion[48];
	char			szDSPVersion[48]; 
	char			szBootTime[48];
	int				iResult;
	char			szDevDesc[24];       //�豸��������
	char			szOEMinfo[24];       //OEM������Ϣ
	char			szIPv4Gateway[16];   //IPv4����
	char			szIPv6Address[46];	 //IPv6��ַ
	char			szIPv6Gateway[46];   //IPv6����
	unsigned char   byIPv6MaskLen;       //IPv6����ǰ׺����
	unsigned char   bySupport;           //��λ��ʾ,��ӦΪΪ1��ʾ֧��,0x01:�Ƿ�֧��Ipv6,0x02:�Ƿ�֧���޸�Ipv6����,0x04:�Ƿ�֧��Dhcp	0x08: �Ƿ�֧��udp�ಥ 0x10:�Ƿ񺬼��ܽڵ�,0x20:�Ƿ�֧�ָֻ�����,0x40:�Ƿ�֧����������,0x80:�Ƿ�֧��ͬ��IPC����			 
	unsigned char   byDhcpEnabled;       //Dhcp״̬, 0 ������ 1 ����
	unsigned char   byDeviceAbility;	//0���豸��֧�֡����豸���������� 'OEM����' 'IPv4����' ��IPv6��ַ�� 'IPv6����' ��IPv6����ǰ׺����DHCP����  1��֧�����߹���
	unsigned short	wHttpPort;			// Http �˿�
	unsigned short	wDigitalChannelNum;
	char			szCmsIPv4[16];
	unsigned short	wCmsPort;
	unsigned char	byOEMCode;  //0-�����豸 1-OEM�豸
	unsigned char   byActivated; //�豸�Ƿ񼤻�;0-���1-δ����ϵ��豸�����Ѽ���״̬��
	char			szBaseDesc[24];	//���߶��ͺţ����涨�ƶ��޸ĵ��ͺţ�����өʯƽ̨�����ͺŶԱ�
   	unsigned char   bySupport1; //��λ��ʾ,  1��ʾ֧�֣�0��ʾ��֧��
                                //0x01:�Ƿ�֧���������뷽ʽ2 
                                //0x02;�Ƿ�֧���豸��������
                                //0x04:�Ƿ�֧�ֵ���GUID��������
                                //0x08:�Ƿ�֧�ְ�ȫ������������
	unsigned char   byHCPlatform; //�Ƿ�֧��HCPlatform 0-������ 1-֧�֣� 2-��֧��   
	unsigned char   byEnableHCPlatform; //�Ƿ�����HCPlatform  0 -���� 1- ���ã� 2- ������
    unsigned char   byEZVIZCode;    //0- �����豸 1- өʯ�豸
    unsigned int    dwDetailOEMCode;    //��ϸOEMCode��Ϣ:oemcode�ɿͻ���ţ��ɱ�λ,��1��ʼ��1~429496)+�˵����2λ��+����ţ�2λ�������ֹ��ɡ�	
									//����˵����oemcode���ֵΪ4294967295�������ʮλ����
	unsigned char   byModifyVerificationCode; //�Ƿ��޸���֤�� 0-������ 1-�޸���֤�룬 2- ���޸���֤��
	unsigned char    byRes2[7];
}SADP_DEVICE_INFO, *LPSADP_DEVICE_INFO;

//���޸ĵ��豸�������
typedef struct tagSADP_DEV_NET_PARAM
{
	char			szIPv4Address[16];		// IPv4��ַ
	char			szIPv4SubNetMask[16];	// IPv4��������
	char			szIPv4Gateway[16];		// IPv4����
	char			szIPv6Address[128];		// IPv6��ַ
	char			szIPv6Gateway[128];		// IPv6����
	unsigned short	wPort;					// �豸�����˿�
	unsigned char	byIPv6MaskLen;			// IPv6���볤��
	unsigned char	byDhcpEnable;			// DHCPʹ��
	unsigned short	wHttpPort;				//HTTP�˿�
	unsigned char	byRes[126];
}SADP_DEV_NET_PARAM, *LPSADP_DEV_NET_PARAM;


//�豸�������������Ϣ
typedef struct tagSADP_DEV_RET_NET_PARAM
{
    unsigned char   byRetryModifyTime;  //ʣ��ɳ����޸������������
    unsigned char   bySurplusLockTime;  //ʣ��ʱ�䣬��λ�����ӣ��û�����ʱ�˲�����Ч
    unsigned char	byRes[126];
}SADP_DEV_RET_NET_PARAM, *LPSADP_DEV_RET_NET_PARAM;

// CMS����
typedef struct tagSADP_CMS_PARAM
{
	char			szPUID[32];			// Ԥ�����PUID
	char			szPassword[16];		// ���õĵ�¼����
	char			szCmsIPv4[16];		// CMS������IPv4��ַ
	char			szCmsIPv6[128];		// CMS������IPv6��ַ
	unsigned short	wCmsPort;			// CMS�����������˿�
	unsigned char	byRes[30];
}SADP_CMS_PARAM, *LPSADP_CMS_PARAM;

//�豸��ȫ�룬��Ӧ��������SADP_GET_DEVICE_CODE���ӿ�SADP_GetDeviceConfig
typedef struct tagSADP_SAFE_CODE
{
	unsigned int    dwCodeSize;
	char            szDeviceCode[MAX_DEVICE_CODE];
	unsigned char   byRes[128];
}SADP_SAFE_CODE, *LPSADP_SAFE_CODE;
//���ܴ��ṹ�壬��Ӧ��������SADP_GET_ENCRYPT_STRING���ӿ�SADP_GetDeviceConfig
typedef struct tagSADP_ENCRYPT_STRING
{
    unsigned int    dwEncryptStringSize;
    char            szEncryptString[MAX_ENCRYPT_CODE];
    unsigned char   byRes[128];
}SADP_ENCRYPT_STRING, *LPSADP_ENCRYPT_STRING;
//�ָ�/��������ṹ��
typedef struct tagSADP_RESET_PARAM
{
    char            szCode[MAX_ENCRYPT_CODE]; //����ת�����������ַ�������ܹ��߼��ܺ���ַ��� - Ϊ�����Ͻӿ�
    char            szAuthFile[MAX_FILE_PATH_LEN];             //������Ȩ�ļ�
    char            szPassword[MAX_PASS_LEN];  //�û�����
    unsigned char   byEnableSyncIPCPW;        //�Ƿ�����ͬ��IPC���롣0 - �����ã� 1- ����
    unsigned char   byRes[511];
}SADP_RESET_PARAM, *LSADP_RESET_PARAM;

//��ʾOEM���ýṹ��
typedef struct tagSADP_DISPLAY_OEM_CFG
{
    unsigned int    dwDisplayOEM;   //0-��ʾ����OEM������ֵΪҪ��ʾ��ĳһ�����͵�OEMCode���������dwDetailOEMCode	
    unsigned char   byRes[32];      //����
}SADP_DISPLAY_OEM_CFG, *LPSADP_DISPLAY_OEM_CFG;

typedef struct tagSADP_TYPE_UNLOCK_CODE
{
    unsigned int dwCodeSize;
    char       szDeviceTypeUnlockCode[MAX_UNLOCK_CODE_RANDOM_LEN/*256*/];//�豸�ͺŽ����
    unsigned char  byRes[128];
}SADP_TYPE_UNLOCK_CODE, *LPSADP_TYPE_UNLOCK_CODE;

typedef struct tagSADP_CUSTOM_DEVICE_TYPE
{
    unsigned int dwCodeSize;
    char       szDeviceTypeSecretKey[MAX_UNLOCK_CODE_KEY/*256*/];//���ͽ����Կ
    unsigned char  byRes[128];
}SADP_CUSTOM_DEVICE_TYPE, *LPSADP_CUSTOM_DEVICE_TYPE;

typedef struct tagSADP_GUID_FILE_COND
{
    char           szPassword[MAX_PASS_LEN];  //�û�����
    unsigned char  byRes[128];
}SADP_GUID_FILE_COND, *LPSADP_GUID_FILE_COND;

typedef struct tagSADP_GUID_FILE
{
    unsigned int    dwGUIDSize;
    char            szGUID[MAX_GUID_LEN];
    unsigned char   byRetryGUIDTime;    //ʣ��ɵ���/����GUID����
    unsigned char   bySurplusLockTime;  //ʣ��ʱ�䣬��λ�����ӣ��û�����ʱ�˲�����Ч
    unsigned char   byRes[254];
}SADP_GUID_FILE, *LPSADP_GUID_FILE;

typedef struct tagSADP_SINGLE_SECURITY_QUESTION_CFG
{
    unsigned int     dwSize;
    unsigned int     dwId;//���
    char             szAnswer[MAX_ANSWER_LEN/*256*/];//�𰸣�ֻ������ʱ��Ч����ȡʱ��Ч
    unsigned char    byMark;//���  0-δ���� 1-������
    unsigned char    byRes[127];
}SADP_SINGLE_SECURITY_QUESTION_CFG, *LPSADP_SINGLE_SECURITY_QUESTION_CFG;

typedef struct tagSADP_SECURITY_QUESTION_CFG
{
    unsigned int   dwSize;
    SADP_SINGLE_SECURITY_QUESTION_CFG  struSecurityQuestion[MAX_QUESTION_LIST_LEN/*32*/];//��ȫ�����б�
    char           szPassword[MAX_PASS_LEN];  //�û�����
    unsigned char  byRes[512];
}SADP_SECURITY_QUESTION_CFG, *LPSADP_SECURITY_QUESTION_CFG;

typedef struct tagSADP_SECURITY_QUESTION
{
    unsigned char   byRetryAnswerTime;  //ʣ������ð�ȫ�������
    unsigned char   bySurplusLockTime;  //ʣ��ʱ�䣬��λ�����ӣ��û�����ʱ�˲�����Ч
    unsigned char   byRes[254];
}SADP_SECURITY_QUESTION, *LPSADP_SECURITY_QUESTION;

typedef struct tagSADP_RESET_PARAM_V40
{
    unsigned int    dwSize;
    unsigned char   byResetType; //������������ 0-����,1- ͨ���豸���кŻָ�Ĭ�����룬2-����/�����ļ��������룬3-��ά�����ã� 4-GUID���ã�5-��ȫ��������
    unsigned char   byEnableSyncIPCPW;        //�Ƿ�����ͬ��IPC���롣0 - �����ã� 1- ����
    unsigned char   byRes2[2];             //����
    char            szPassword[MAX_PASS_LEN];  //�û�����
    char            szCode[MAX_ENCRYPT_CODE]; //����ת�����������ַ�������ܹ��߼��ܺ���ַ��� - byResetType Ϊ1��3ʱ��Ч
    char            szAuthFile[MAX_FILE_PATH_LEN];             //������Ȩ�ļ��� byResetType Ϊ2ʱ��Ч
    char            szGUID[MAX_GUID_LEN]; //GUID, byResetType Ϊ4ʱ��Ч
    SADP_SECURITY_QUESTION_CFG struSecurityQuestionCfg; //��ȫ����ṹ�壬 byResetType Ϊ5ʱ��Ч
    unsigned char   byRes[512];
}SADP_RESET_PARAM_V40, *LPSADP_RESET_PARAM_V40;

typedef struct tagSADP_RET_RESET_PARAM_V40
{
    unsigned char   byRetryGUIDTime;  //ʣ������ð�ȫ�������
    unsigned char   bySurplusLockTime;  //ʣ��ʱ�䣬��λ�����ӣ��û�����ʱ�˲�����Ч
    unsigned char   byRes[254];
}SADP_RET_RESET_PARAM_V40, *LPSADP_RET_RESET_PARAM_V40;

//HCPlatform״̬
typedef struct tagSADP_HCPLATFORM_STATUS_INFO
{
	unsigned int    dwSize;
	unsigned char   byEnableHCPlatform;        //�Ƿ�����HCPlatform��0 - ������ 1- ���ã� 2-����
	unsigned char   byRes[3];             //����
	char            szPassword[MAX_PASS_LEN];  //�û�����
	unsigned char	byRes2[128];
}SADP_HCPLATFORM_STATUS_INFO, *LPSADP_HCPLATFORM_STATUS_INFO;

//�豸��֤��
typedef struct tagSADP_VERIFICATION_CODE_INFO
{
	unsigned int    dwSize;
	char            szVerificationCode[SADP_MAX_VERIFICATION_CODE_LEN];  //��֤��
	char            szPassword[MAX_PASS_LEN];  //�û�����
	unsigned char	byRes[128];
}SADP_VERIFICATION_CODE_INFO, *LPSADP_VERIFICATION_CODE_INFO;

//�豸������Ϣ
typedef struct tagSADP_DEV_LOCK_INFO
{
	unsigned char   byRetryTime;  //ʣ��ɳ��Դ���
	unsigned char   bySurplusLockTime;  //ʣ��ʱ�䣬��λ�����ӣ��û�����ʱ�˲�����Ч
	unsigned char	byRes[126];
}SADP_DEV_LOCK_INFO, *LPSADP_DEV_LOCK_INFO;



// �ӿ�
typedef void (CALLBACK *PDEVICE_FIND_CALLBACK)(const SADP_DEVICE_INFO *lpDeviceInfo, void *pUserData);
CSADP_API BOOLNew CALLBACK SADP_Start_V30(PDEVICE_FIND_CALLBACK pDeviceFindCallBack, int bInstallNPF = 0, void* pUserData = NULL);
CSADP_API BOOLNew  CALLBACK SADP_SendInquiry(void);
CSADP_API BOOLNew  CALLBACK SADP_Stop(void);
CSADP_API BOOLNew CALLBACK SADP_ModifyDeviceNetParam(const char* sMAC, const char* sPassword, const SADP_DEV_NET_PARAM *lpNetParam);
CSADP_API unsigned int CALLBACK SADP_GetSadpVersion(void);
CSADP_API BOOLNew CALLBACK SADP_SetLogToFile(int nLogLevel=0, char const *strLogDir = NULL, int bAutoDel = 1);
CSADP_API unsigned int CALLBACK SADP_GetLastError(void);
CSADP_API BOOLNew CALLBACK SADP_ResetDefaultPasswd(const char* sDevSerialNO, const char* sCommand);
CSADP_API BOOLNew CALLBACK SADP_SetCMSInfo(const char* sMac, const SADP_CMS_PARAM *lpCmsParam);
CSADP_API BOOLNew CALLBACK SADP_Clearup(void);
CSADP_API void CALLBACK SADP_SetAutoRequestInterval(unsigned int dwInterval);

CSADP_API BOOLNew CALLBACK SADP_GetDeviceConfig(const char* sDevSerialNO, unsigned int dwCommand,void* lpInBuffer, unsigned int  dwinBuffSize, void *lpOutBuffer, unsigned int  dwOutBuffSize);
CSADP_API BOOLNew CALLBACK SADP_SetDeviceConfig(const char* sDevSerialNO, unsigned int dwCommand, void* lpInBuffer, unsigned int  dwInBuffSize, void* lpOutBuffer, unsigned int  dwOutBuffSize);
//�����豸
CSADP_API BOOLNew CALLBACK SADP_ActivateDevice(const char* sDevSerialNO, const char* sCommand);

//��������ӿڣ�����֮ǰ�Ļָ�Ĭ������ӿ�
CSADP_API BOOLNew CALLBACK SADP_ResetPasswd(const char* sDevSerialNO, const SADP_RESET_PARAM *pResetParam);
//��������ӿ�V40������֮ǰ��SADP_ResetPasswd
CSADP_API BOOLNew CALLBACK SADP_ResetPasswd_V40(const char* sDevSerialNO, const SADP_RESET_PARAM_V40 *pResetParam, SADP_RET_RESET_PARAM_V40 *pRetResetParam);
//Wifi Config�ӿ�
CSADP_API BOOLNew CALLBACK CALLBACK SADP_StartWifiConfig(const char* sWifiSSID, const char* sKey);
CSADP_API void CALLBACK CALLBACK SADP_StopWifiConfig();

//�����豸���˹���
//dwFilterRule,��λ��ʾ��Ϊ1��ʾ���ˣ�ȫ0��ʾ������;0x01:����өʯ�豸;0x02:����OEM�豸;0x03:����ө��OEM�豸;0xfffffffe:����ʾөʯ�豸;0xfffffffd:����ʾOEM�豸
CSADP_API BOOLNew CALLBACK SADP_SetDeviceFilterRule( unsigned int dwFilterRule, const void *lpInBuff, unsigned int dwInBuffLen);
//�޸��������V40
CSADP_API BOOLNew CALLBACK SADP_ModifyDeviceNetParam_V40(const char* sMAC, const char* sPassword, const SADP_DEV_NET_PARAM *lpNetParam, SADP_DEV_RET_NET_PARAM *lpRetNetParam, unsigned int  dwOutBuffSize);
#endif




