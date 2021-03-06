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

//消息操作的类型
#define SADP_ADD		  1			//增加一设备
#define SADP_UPDATE		  2			//更新设备
#define SADP_DEC		  3			//设备下线
#define SADP_RESTART	  4			//设备重新启动
#define SADP_UPDATEFAIL	  5			//设备更新失败

//外部命令码
#define SADP_GET_DEVICE_CODE   1			//获取设备码，对应结构体SADP_SAFE_CODE
#define SADP_GET_ENCRYPT_STRING   2			//获取加密串，对应结构体SADP_ENCRYPT_STRING

#define SADP_GET_DEVICE_TYPE_UNLOCK_CODE    3   //获取设备类型解码，对应的结构体SADP_TYPE_UNLOCK_CODE
#define SADP_SET_DEVICE_CUSTOM_TYPE         4   //设置设备自定义型号，对应的结构体SADP_CUSTOM_DEVICE_TYPE

#define SADP_GET_GUID                       5   //获取GUID
#define SADP_GET_SECURITY_QUESTION          6   //获取安全问题
#define SADP_SET_SECURITY_QUESTION          7   //设置安全问题

#define SADP_SET_HCPLATFORM_STATUS          8   //设置HCPLATFORM状态
#define SADP_SET_VERIFICATION_CODE          9   //设置验证码（验证码用于萤石接入、预览、控制的唯一密码）

#define MAX_DEVICE_CODE     128  //设备返回码长度，暂定最大128
#define MAX_EXCHANGE_CODE   256  //交换码长度
#define MAX_PASS_LEN           16  //设备最大密码长度
#define MAX_FILE_PATH_LEN      260 //文件最大路径长度
#define MAX_ENCRYPT_CODE     256  //设备返回码加密后长度

#define MAX_UNLOCK_CODE_RANDOM_LEN  256   // 解禁码随机串
#define MAX_UNLOCK_CODE_KEY         256   // 解禁密钥

#define MAX_GUID_LEN           128 //GUID长度
#define MAX_QUESTION_LIST_LEN  32  //最多问题列表个数
#define MAX_ANSWER_LEN         256 //最大答案长度
#define SADP_MAX_VERIFICATION_CODE_LEN         12 //最大验证码长度

// 错误码
#define SADP_ERROR_BASE					2000
#define SADP_NOERROR 					0					  // 没有错误
#define SADP_ALLOC_RESOURCE_ERROR		(SADP_ERROR_BASE+1)   // 资源分配错误
#define SADP_NOT_START_ERROR			(SADP_ERROR_BASE+2)   // SADP未启动
#define SADP_NO_ADAPTER_ERROR			(SADP_ERROR_BASE+3)   // 无网卡
#define SADP_GET_ADAPTER_FAIL_ERROR		(SADP_ERROR_BASE+4)   // 获取网卡信息失败
#define SADP_PARAMETER_ERROR			(SADP_ERROR_BASE+5)   // 参数错误
#define SADP_OPEN_ADAPTER_FAIL_ERROR	(SADP_ERROR_BASE+6)   // 打开网卡失败
#define SADP_SEND_PACKET_FAIL_ERROR		(SADP_ERROR_BASE+7)   // 发送数据失败
#define SADP_SYSTEM_CALL_ERROR			(SADP_ERROR_BASE+8)   // 系统接口调用失败
#define SADP_DEVICE_DENY		        (SADP_ERROR_BASE+9)   // 设备拒绝处理
#define SADP_NPF_INSTALL_ERROR			(SADP_ERROR_BASE+10)  // 安装NPF服务失败
#define SADP_TIMEOUT					(SADP_ERROR_BASE+11)  // 设备超时
#define SADP_CREATE_SOCKET_ERROR		(SADP_ERROR_BASE+12)  // 创建socket失败
#define SADP_BIND_SOCKET_ERROR			(SADP_ERROR_BASE+13)  // 绑定socket失败
#define SADP_JOIN_MULTI_CAST_ERROR		(SADP_ERROR_BASE+14)  // 加入多播组失败
#define SADP_NETWORK_SEND_ERROR			(SADP_ERROR_BASE+15)  // 发送出错
#define SADP_NETWORK_RECV_ERROR			(SADP_ERROR_BASE+16)  // 接收出错
#define SADP_XML_PARSE_ERROR			(SADP_ERROR_BASE+17)  // 多播XML解析出错
#define SADP_LOCKED						(SADP_ERROR_BASE+18)  // 设备锁定
#define SADP_NOT_ACTIVATED              (SADP_ERROR_BASE+19)  // 设备未激活
#define SADP_RISK_PASSWORD              (SADP_ERROR_BASE+20)  // 风险高的密码
#define SADP_HAS_ACTIVATED              (SADP_ERROR_BASE+21)  // 设备已激活
#define SADP_EMPTY_ENCRYPT_STRING       (SADP_ERROR_BASE+22)  // 加密串为空
#define SADP_EXPORT_FILE_OVERDUE        (SADP_ERROR_BASE+23)  // 导出文件超期
#define SADP_PASSWORD_ERROR             (SADP_ERROR_BASE+24)  // 密码错误
#define SADP_LONG_SECURITY_ANSWER       (SADP_ERROR_BASE+25)  // 安全问题答案太长
#define SADP_INVALID_GUID               (SADP_ERROR_BASE+26)  // 无效的GUID
#define SADP_ANSWER_ERROR               (SADP_ERROR_BASE+27)  // 答案错误
#define SADP_QUESTION_NUM_ERR           (SADP_ERROR_BASE+28)  // 安全问题个数配置错误
#define SADP_LOAD_WPCAP_FAIL            (SADP_ERROR_BASE+30)  // 加载Wpcap失败
#define SADP_ILLEGAL_VERIFICATION_CODE     (SADP_ERROR_BASE+33)  // 非法验证码


//SADP设备过滤规则类型
//按位表示，为1表示过滤，0表示不过滤;
//bit 1:是否过滤萤石;bit 2:是否过滤OEM;
#define SADP_DISPLAY_ALL           0            //显示所有设备
#define SADP_FILTER_EZVIZ          0x01         //过滤萤石设备
#define SADP_FILTER_OEM            0x02         //过滤OEM设备
#define SADP_FILTER_EZVIZ_OEM      0x03         //同时过滤萤石和OEM设备
#define SADP_ONLY_DISPLAY_OEM      0xfffffffd   //仅显示OEM设备,对应结构体SADP_DISPLAY_OEM_CFG
#define SADP_ONLY_DISPLAY_EZVIZ    0xfffffffe   //仅显示萤石设备
// 结构体
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
	char			szDevDesc[24];       //设备类型描述
	char			szOEMinfo[24];       //OEM产商信息
	char			szIPv4Gateway[16];   //IPv4网关
	char			szIPv6Address[46];	 //IPv6地址
	char			szIPv6Gateway[46];   //IPv6网关
	unsigned char   byIPv6MaskLen;       //IPv6子网前缀长度
	unsigned char   bySupport;           //按位表示,对应为为1表示支持,0x01:是否支持Ipv6,0x02:是否支持修改Ipv6参数,0x04:是否支持Dhcp	0x08: 是否支持udp多播 0x10:是否含加密节点,0x20:是否支持恢复密码,0x40:是否支持重置密码,0x80:是否支持同步IPC密码			 
	unsigned char   byDhcpEnabled;       //Dhcp状态, 0 不启用 1 启用
	unsigned char   byDeviceAbility;	//0：设备不支持“‘设备类型描述’ 'OEM厂商' 'IPv4网关' ‘IPv6地址’ 'IPv6网关' ‘IPv6子网前缀’‘DHCP’”  1：支持上诉功能
	unsigned short	wHttpPort;			// Http 端口
	unsigned short	wDigitalChannelNum;
	char			szCmsIPv4[16];
	unsigned short	wCmsPort;
	unsigned char	byOEMCode;  //0-基线设备 1-OEM设备
	unsigned char   byActivated; //设备是否激活;0-激活，1-未激活（老的设备都是已激活状态）
	char			szBaseDesc[24];	//基线短型号，不随定制而修改的型号，用于萤石平台进行型号对比
   	unsigned char   bySupport1; //按位表示,  1表示支持，0表示不支持
                                //0x01:是否支持重置密码方式2 
                                //0x02;是否支持设备锁定功能
                                //0x04:是否支持导入GUID重置密码
                                //0x08:是否支持安全问题重置密码
	unsigned char   byHCPlatform; //是否支持HCPlatform 0-保留， 1-支持， 2-不支持   
	unsigned char   byEnableHCPlatform; //是否启用HCPlatform  0 -保留 1- 启用， 2- 不启用
    unsigned char   byEZVIZCode;    //0- 基线设备 1- 萤石设备
    unsigned int    dwDetailOEMCode;    //详细OEMCode信息:oemcode由客户序号（可变位,从1开始，1~429496)+菜单风格（2位）+区域号（2位）三部分构成。	
									//规则说明：oemcode最大值为4294967295，最多是十位数。
	unsigned char   byModifyVerificationCode; //是否修改验证码 0-保留， 1-修改验证码， 2- 不修改验证码
	unsigned char    byRes2[7];
}SADP_DEVICE_INFO, *LPSADP_DEVICE_INFO;

//待修改的设备网络参数
typedef struct tagSADP_DEV_NET_PARAM
{
	char			szIPv4Address[16];		// IPv4地址
	char			szIPv4SubNetMask[16];	// IPv4子网掩码
	char			szIPv4Gateway[16];		// IPv4网关
	char			szIPv6Address[128];		// IPv6地址
	char			szIPv6Gateway[128];		// IPv6网关
	unsigned short	wPort;					// 设备监听端口
	unsigned char	byIPv6MaskLen;			// IPv6掩码长度
	unsigned char	byDhcpEnable;			// DHCP使能
	unsigned short	wHttpPort;				//HTTP端口
	unsigned char	byRes[126];
}SADP_DEV_NET_PARAM, *LPSADP_DEV_NET_PARAM;


//设备返回网络参数信息
typedef struct tagSADP_DEV_RET_NET_PARAM
{
    unsigned char   byRetryModifyTime;  //剩余可尝试修改网络参数次数
    unsigned char   bySurplusLockTime;  //剩余时间，单位：分钟，用户锁定时此参数有效
    unsigned char	byRes[126];
}SADP_DEV_RET_NET_PARAM, *LPSADP_DEV_RET_NET_PARAM;

// CMS参数
typedef struct tagSADP_CMS_PARAM
{
	char			szPUID[32];			// 预分配的PUID
	char			szPassword[16];		// 设置的登录密码
	char			szCmsIPv4[16];		// CMS服务器IPv4地址
	char			szCmsIPv6[128];		// CMS服务器IPv6地址
	unsigned short	wCmsPort;			// CMS服务器监听端口
	unsigned char	byRes[30];
}SADP_CMS_PARAM, *LPSADP_CMS_PARAM;

//设备安全码，对应配置命令SADP_GET_DEVICE_CODE，接口SADP_GetDeviceConfig
typedef struct tagSADP_SAFE_CODE
{
	unsigned int    dwCodeSize;
	char            szDeviceCode[MAX_DEVICE_CODE];
	unsigned char   byRes[128];
}SADP_SAFE_CODE, *LPSADP_SAFE_CODE;
//加密串结构体，对应配置命令SADP_GET_ENCRYPT_STRING，接口SADP_GetDeviceConfig
typedef struct tagSADP_ENCRYPT_STRING
{
    unsigned int    dwEncryptStringSize;
    char            szEncryptString[MAX_ENCRYPT_CODE];
    unsigned char   byRes[128];
}SADP_ENCRYPT_STRING, *LPSADP_ENCRYPT_STRING;
//恢复/重置密码结构体
typedef struct tagSADP_RESET_PARAM
{
    char            szCode[MAX_ENCRYPT_CODE]; //日期转换过的特殊字符串或加密工具加密后的字符串 - 为兼容老接口
    char            szAuthFile[MAX_FILE_PATH_LEN];             //重置授权文件
    char            szPassword[MAX_PASS_LEN];  //用户密码
    unsigned char   byEnableSyncIPCPW;        //是否启用同步IPC密码。0 - 不启用， 1- 启用
    unsigned char   byRes[511];
}SADP_RESET_PARAM, *LSADP_RESET_PARAM;

//显示OEM配置结构体
typedef struct tagSADP_DISPLAY_OEM_CFG
{
    unsigned int    dwDisplayOEM;   //0-显示所有OEM，其它值为要显示的某一种类型的OEMCode，具体详见dwDetailOEMCode	
    unsigned char   byRes[32];      //保留
}SADP_DISPLAY_OEM_CFG, *LPSADP_DISPLAY_OEM_CFG;

typedef struct tagSADP_TYPE_UNLOCK_CODE
{
    unsigned int dwCodeSize;
    char       szDeviceTypeUnlockCode[MAX_UNLOCK_CODE_RANDOM_LEN/*256*/];//设备型号解禁码
    unsigned char  byRes[128];
}SADP_TYPE_UNLOCK_CODE, *LPSADP_TYPE_UNLOCK_CODE;

typedef struct tagSADP_CUSTOM_DEVICE_TYPE
{
    unsigned int dwCodeSize;
    char       szDeviceTypeSecretKey[MAX_UNLOCK_CODE_KEY/*256*/];//类型解禁秘钥
    unsigned char  byRes[128];
}SADP_CUSTOM_DEVICE_TYPE, *LPSADP_CUSTOM_DEVICE_TYPE;

typedef struct tagSADP_GUID_FILE_COND
{
    char           szPassword[MAX_PASS_LEN];  //用户密码
    unsigned char  byRes[128];
}SADP_GUID_FILE_COND, *LPSADP_GUID_FILE_COND;

typedef struct tagSADP_GUID_FILE
{
    unsigned int    dwGUIDSize;
    char            szGUID[MAX_GUID_LEN];
    unsigned char   byRetryGUIDTime;    //剩余可导入/导出GUID次数
    unsigned char   bySurplusLockTime;  //剩余时间，单位：分钟，用户锁定时此参数有效
    unsigned char   byRes[254];
}SADP_GUID_FILE, *LPSADP_GUID_FILE;

typedef struct tagSADP_SINGLE_SECURITY_QUESTION_CFG
{
    unsigned int     dwSize;
    unsigned int     dwId;//序号
    char             szAnswer[MAX_ANSWER_LEN/*256*/];//答案，只在设置时有效，获取时无效
    unsigned char    byMark;//标记  0-未设置 1-已设置
    unsigned char    byRes[127];
}SADP_SINGLE_SECURITY_QUESTION_CFG, *LPSADP_SINGLE_SECURITY_QUESTION_CFG;

typedef struct tagSADP_SECURITY_QUESTION_CFG
{
    unsigned int   dwSize;
    SADP_SINGLE_SECURITY_QUESTION_CFG  struSecurityQuestion[MAX_QUESTION_LIST_LEN/*32*/];//安全问题列表
    char           szPassword[MAX_PASS_LEN];  //用户密码
    unsigned char  byRes[512];
}SADP_SECURITY_QUESTION_CFG, *LPSADP_SECURITY_QUESTION_CFG;

typedef struct tagSADP_SECURITY_QUESTION
{
    unsigned char   byRetryAnswerTime;  //剩余可设置安全问题次数
    unsigned char   bySurplusLockTime;  //剩余时间，单位：分钟，用户锁定时此参数有效
    unsigned char   byRes[254];
}SADP_SECURITY_QUESTION, *LPSADP_SECURITY_QUESTION;

typedef struct tagSADP_RESET_PARAM_V40
{
    unsigned int    dwSize;
    unsigned char   byResetType; //密码重置类型 0-保留,1- 通过设备序列号恢复默认密码，2-导入/导出文件重置密码，3-二维码重置， 4-GUID重置，5-安全问题重置
    unsigned char   byEnableSyncIPCPW;        //是否启用同步IPC密码。0 - 不启用， 1- 启用
    unsigned char   byRes2[2];             //保留
    char            szPassword[MAX_PASS_LEN];  //用户密码
    char            szCode[MAX_ENCRYPT_CODE]; //日期转换过的特殊字符串或加密工具加密后的字符串 - byResetType 为1、3时有效
    char            szAuthFile[MAX_FILE_PATH_LEN];             //重置授权文件， byResetType 为2时有效
    char            szGUID[MAX_GUID_LEN]; //GUID, byResetType 为4时有效
    SADP_SECURITY_QUESTION_CFG struSecurityQuestionCfg; //安全问题结构体， byResetType 为5时有效
    unsigned char   byRes[512];
}SADP_RESET_PARAM_V40, *LPSADP_RESET_PARAM_V40;

typedef struct tagSADP_RET_RESET_PARAM_V40
{
    unsigned char   byRetryGUIDTime;  //剩余可设置安全问题次数
    unsigned char   bySurplusLockTime;  //剩余时间，单位：分钟，用户锁定时此参数有效
    unsigned char   byRes[254];
}SADP_RET_RESET_PARAM_V40, *LPSADP_RET_RESET_PARAM_V40;

//HCPlatform状态
typedef struct tagSADP_HCPLATFORM_STATUS_INFO
{
	unsigned int    dwSize;
	unsigned char   byEnableHCPlatform;        //是否启用HCPlatform。0 - 保留， 1- 启用， 2-启用
	unsigned char   byRes[3];             //保留
	char            szPassword[MAX_PASS_LEN];  //用户密码
	unsigned char	byRes2[128];
}SADP_HCPLATFORM_STATUS_INFO, *LPSADP_HCPLATFORM_STATUS_INFO;

//设备验证码
typedef struct tagSADP_VERIFICATION_CODE_INFO
{
	unsigned int    dwSize;
	char            szVerificationCode[SADP_MAX_VERIFICATION_CODE_LEN];  //验证码
	char            szPassword[MAX_PASS_LEN];  //用户密码
	unsigned char	byRes[128];
}SADP_VERIFICATION_CODE_INFO, *LPSADP_VERIFICATION_CODE_INFO;

//设备锁定信息
typedef struct tagSADP_DEV_LOCK_INFO
{
	unsigned char   byRetryTime;  //剩余可尝试次数
	unsigned char   bySurplusLockTime;  //剩余时间，单位：分钟，用户锁定时此参数有效
	unsigned char	byRes[126];
}SADP_DEV_LOCK_INFO, *LPSADP_DEV_LOCK_INFO;



// 接口
typedef void (CALLBACK *PDEVICE_FIND_CALLBACK)(const SADP_DEVICE_INFO *lpDeviceInfo, void *pUserData);
CSADP_API BOOL CALLBACK SADP_Start_V30(PDEVICE_FIND_CALLBACK pDeviceFindCallBack, int bInstallNPF = 0, void* pUserData = NULL);
CSADP_API BOOL  CALLBACK SADP_SendInquiry(void);
CSADP_API BOOL  CALLBACK SADP_Stop(void);
CSADP_API BOOL CALLBACK SADP_ModifyDeviceNetParam(const char* sMAC, const char* sPassword, const SADP_DEV_NET_PARAM *lpNetParam);
CSADP_API unsigned int CALLBACK SADP_GetSadpVersion(void);
CSADP_API BOOL CALLBACK SADP_SetLogToFile(int nLogLevel=0, char const *strLogDir = NULL, int bAutoDel = 1);		
CSADP_API unsigned int CALLBACK SADP_GetLastError(void);
CSADP_API BOOL CALLBACK SADP_ResetDefaultPasswd(const char* sDevSerialNO, const char* sCommand);
CSADP_API BOOL CALLBACK SADP_SetCMSInfo(const char* sMac, const SADP_CMS_PARAM *lpCmsParam);
CSADP_API BOOL CALLBACK SADP_Clearup(void);
CSADP_API void CALLBACK SADP_SetAutoRequestInterval(unsigned int dwInterval);

CSADP_API BOOL CALLBACK SADP_GetDeviceConfig(const char* sDevSerialNO, unsigned int dwCommand,void* lpInBuffer, unsigned int  dwinBuffSize, void *lpOutBuffer, unsigned int  dwOutBuffSize);
CSADP_API BOOL CALLBACK SADP_SetDeviceConfig(const char* sDevSerialNO, unsigned int dwCommand, void* lpInBuffer, unsigned int  dwInBuffSize, void* lpOutBuffer, unsigned int  dwOutBuffSize);
//激活设备
CSADP_API BOOL CALLBACK SADP_ActivateDevice(const char* sDevSerialNO, const char* sCommand);

//重置密码接口，兼容之前的恢复默认密码接口
CSADP_API BOOL CALLBACK SADP_ResetPasswd(const char* sDevSerialNO, const SADP_RESET_PARAM *pResetParam);
//重置密码接口V40，兼容之前的SADP_ResetPasswd
CSADP_API BOOL CALLBACK SADP_ResetPasswd_V40(const char* sDevSerialNO, const SADP_RESET_PARAM_V40 *pResetParam, SADP_RET_RESET_PARAM_V40 *pRetResetParam);


//设置设备过滤规则
//dwFilterRule,按位表示，为1表示过滤，全0表示不过滤;0x01:过滤萤石设备;0x02:过滤OEM设备;0x03:过滤萤和OEM设备;0xfffffffe:仅显示萤石设备;0xfffffffd:仅显示OEM设备
CSADP_API BOOL CALLBACK SADP_SetDeviceFilterRule( unsigned int dwFilterRule, const void *lpInBuff, unsigned int dwInBuffLen);
//修改网络参数V40
CSADP_API BOOL CALLBACK SADP_ModifyDeviceNetParam_V40(const char* sMAC, const char* sPassword, const SADP_DEV_NET_PARAM *lpNetParam, SADP_DEV_RET_NET_PARAM *lpRetNetParam, unsigned int  dwOutBuffSize);
#endif




