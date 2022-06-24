//
// Created by zhou rui on 2017/12/23.
//

#ifndef ZRDREAM_JWTYPE_JW_TYPE_H
#define ZRDREAM_JWTYPE_JW_TYPE_H

#include <stdint.h>
#include <string.h>

#define MSG_ID_CONNECT_RESULT 1
#define MSG_ID_SPEED_RESULT 2
#define MSG_ID_SEEK_RESULT 3
#define MSG_ID_PAUSE_RESULT 4
#define MSG_ID_RESUME_RESULT 5

/**
 * 帧类型
 */
// 关键帧
#define JW_FRAME_TYPE_KEY_FRAME 1
// 帧内预测帧
#define JW_FRAME_TYPE_INTER_FRAME 2
// H.263 ONLY
#define JW_FRAME_TYPE_DISPOSABLE_INTER_FRAME 3
// 生成的关键帧(保留只给服务器使用)
#define JW_FRAME_TYPE_GENERATED_KEY_FRAME 4
// 视频信息/控制帧
#define JW_FRAME_TYPE_VIDEO_INFO_COMMAND_FRAME 5

/**
 * 编解码器
 */
#define JW_CODEC_ID_H263 2
#define JW_CODEC_ID_SCREEN_VIDEO 3
#define JW_CODEC_ID_ON2_VP6 4
#define JW_CODEC_ID_ON2_VP6_WITH_ALPHA_CHANNEL 5
#define JW_CODEC_ID_SCREEN_VIDEO_VERSION_2 6
#define JW_CODEC_ID_AVC 7
#define JW_CODEC_ID_HEVC 8

/**
 * avc包类型
 */
#define JW_AVC_PACKET_TYPE_SEQUENCE_HEADER 0
#define JW_AVC_PACKET_TYPE_NALU 1
#define JW_AVC_PACKET_TYPE_END_OF_SEQUENCE 2

/**
 * 视频TAG结构
 */
typedef struct {
    uint64_t utcTimeStamp;  // utc时间, 可能为0
    uint32_t timeStamp;    /* timestamp */
    uint8_t frameType;  // 帧类型
    uint8_t codecId;  // 编解码器id
    uint8_t avcPacketType;  // avc包类型，当codecId == 7时才生效
    int32_t compositionTime;  // 成分时间偏移, 当avcPacketType == 1时才有效，否则都为0

    char *data;  // 视频数据
    size_t dataLen;  // 视频数据长度
} JWVideoTag;


/**
 * 音频格式
 */
#define JW_SOUND_FORMAT_LINEAR_PCM_PLATFORM_ENDIAN 0x00
#define JW_SOUND_FORMAT_ADPCM 0x01
#define JW_SOUND_FORMAT_MP3 0x02
#define JW_SOUND_FORMAT_LINEAR_PCM_LITTLE_ENDIAN 0x03
#define JW_SOUND_FORMAT_NELLYMOSER_16KHZ_MONO 0x04
#define JW_SOUND_FORMAT_NELLYMOSER_8KHZ_MONO 0x05
#define JW_SOUND_FORMAT_NELLYMOSER 0x06
#define JW_SOUND_FORMAT_G711A 0x07
#define JW_SOUND_FORMAT_G711U 0x08
#define JW_SOUND_FORMAT_RESERVED 0x09
#define JW_SOUND_FORMAT_AAC 0x0A
#define JW_SOUND_FORMAT_SPEEX 0x0B
#define JW_SOUND_FORMAT_MP3_8KHZ 0x0E
#define JW_SOUND_FORMAT_DEVICE_SPECIFIC_SOUND 0x0F

/**
 * 采样率
 */
// 5.5 kHz
#define JW_SOUND_RATE_5_5KHZ 0
// 11 kHz
#define JW_SOUND_RATE_11KHZ 1
// 22 kHz
#define JW_SOUND_RATE_22KHZ 2
// 44 kHz
#define JW_SOUND_RATE_44KHZ 3

// 8 kHz
#define JW_SOUND_RATE_8KHZ 0x0B
// 16 kHz
#define JW_SOUND_RATE_16KHZ 0x08

/**
 * 采样精度
 */
#define JW_SOUND_SIZE_8BIT 0
// 压缩过的音频都是16bit
#define JW_SOUND_SIZE_16BIT 1

/**
 * 声道数
 */
// 单声道
#define JW_SOUND_TYPE_MONO 0
// 立体声 aac总是立体声
#define JW_SOUND_TYPE_STEREO 1

/**
 * aac包类型
 */
#define JW_AAC_PACKET_TYPE_SEQUENCE_HEADER 0
#define JW_AAC_PACKET_TYPE_RAW 1

/**
 * aac描述 这是rtmp中的描述而已，在adts中，描述的值是需要减1
 */
#define JW_AAC_PROFILE_MAIN 0x01
#define JW_AAC_PROFILE_LC 0x02
#define JW_AAC_PROFILE_SSR 0x03

/**
 * aac采样率
 */
#define JW_AAC_SOUND_RATE_96000 0x00
#define JW_AAC_SOUND_RATE_88200 0x01
#define JW_AAC_SOUND_RATE_64000 0x02
#define JW_AAC_SOUND_RATE_48000 0x03
#define JW_AAC_SOUND_RATE_44100 0x04
#define JW_AAC_SOUND_RATE_32000 0x05
#define JW_AAC_SOUND_RATE_24000 0x06
#define JW_AAC_SOUND_RATE_22050 0x07
#define JW_AAC_SOUND_RATE_16000 0x08
#define JW_AAC_SOUND_RATE_12000 0x09
#define JW_AAC_SOUND_RATE_11025 0x0A
#define JW_AAC_SOUND_RATE_8000 0x0B
#define JW_AAC_SOUND_RATE_7350 0x0C

/**
 * aac声道数
 */
#define JW_AAC_SOUND_TYPE_DEFINED_IN_AOT_SPECIFIC_CONFIG 0x00
// 单声道
#define JW_AAC_SOUND_TYPE_ONE 0x01
// 双声道
#define JW_AAC_SOUND_TYPE_TWO 0x02
// 三声道
#define JW_AAC_SOUND_TYPE_THREE 0x03
// 四声道
#define JW_AAC_SOUND_TYPE_FOUR 0x04
// 五声道
#define JW_AAC_SOUND_TYPE_FIVE 0x05
// 5.1声道
#define JW_AAC_SOUND_TYPE_FIVE_ONE 0x06
// 7.1声道
#define JW_AAC_SOUND_TYPE_SEVEN_ONE 0x07

/**
 * 音频TAG结构
 */
typedef struct {
    uint64_t utcTimeStamp;
    uint32_t timeStamp;    /* timestamp */
    uint8_t soundFormat;  // 音频格式
    uint8_t soundRate;  // 采样率
    uint8_t soundSize;  // 采样精度
    uint8_t soundType;  // 声道数
    uint8_t aacPacketType;  // aac包类型 0: AAC sequence header(参数信息); 1: AAC raw(数据)

    // 当aacPacketType为0时才有意义
    uint8_t aacProfile;  // aac描述
    uint8_t aacSoundRate;  // aac采样率
    uint8_t aacSoundType;  // aac声道数

    // 当aacPacketType为1时才有意义
    char *data;
    size_t dataLen;
} JWAudioTag;


/**
 * 媒体数据结构
 */
typedef struct {
    double duration;  // 总时长 (秒)
    double fileSize;  // 文件大小 (字节)
    char *creationData;  // 创建日期时间

    uint8_t canSeekToEnd;  // 表示最后一个视频帧是关键帧
    double frameRate;  // 帧率
    double width;  // 宽度像素
    double height;  // 高度像素
    double videoCodecId;  // 视频编解码器
    double videoDataRate;  // 视频码率 (位/秒)

    double audioCodecId;  // 音频编解码器
    uint8_t stereo;  // 是否立体声
    double audioSampleRate;  // 音频采样率
    double audioSampleSize;  // 音频采样精度
    double audioDataRate;  // 音频码率 (位/秒)
    double audioDelay;  // 音频编解码引入的延时 (秒)
} JWMetaData;

/**
 * 结果回调
 */
typedef void (*fJWResultCallBack)(int32_t handle, int msg, int success, void *user);

/**
 * 连接码流状态回调
 */
typedef void (*fJWConnectStreamCallBack)(int32_t handle, int connect, void *user);

/**
 * 视频TAG回调函数
 */
typedef void (*fJWVideoTagCallBack)(int32_t handle, const JWVideoTag *videoTag, void *user);

/**
 * 音频TAG回调函数
 */
typedef void (*fJWAudioTagCallBack)(int32_t handle, const JWAudioTag *audioTag, void *user);

/**
 * 流量信息回调
 */
typedef void (*fJWFlowInfoCallBack)(int32_t handle, int64_t flowBytes, int32_t byteRate, void *user);

#endif //ZRDREAM_JW_TYPE_H
