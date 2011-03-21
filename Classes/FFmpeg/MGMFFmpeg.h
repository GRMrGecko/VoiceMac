//
//  MGMFFmpeg.h
//  VoiceBase
//
//  Created by Mr. Gecko on 2/25/11.
//  MGMFFmpeg is a port of ffmpeg.c to Objective-C by Mr. Gecko's Media
//    (James Coleman) FFmpeg can be found at http://ffmpeg.org/
//  FFmpeg Copyright (c) 2000-2003 Fabrice Bellard
//
//  MGMFFmpeg is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
//
//  MGMFFmpeg is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with MGMFFmpeg; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
//

#if MGMSIPENABLED
#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavdevice/avdevice.h>
#import <libswscale/swscale.h>
#import <libavcodec/opt.h>
#import <libavcodec/audioconvert.h>
#import <libavcodec/colorspace.h>
#import <libavutil/fifo.h>
#import <libavutil/pixdesc.h>
#import <libavutil/avstring.h>
#import <ffconfig.h>

#if HAVE_TERMIOS_H
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <termios.h>
#elif HAVE_CONIO_H
#include <conio.h>
#endif
#include <time.h>

@protocol MGMFFmpegDelegate <NSObject>
- (void)receivedError:(NSError *)theError;
- (void)updateStatus:(double)thePercentDone estimatedTime:(double)theEstimatedTime currentFrame:(int)theFrame fps:(int)theFPS quality:(double)theQuality size:(int64_t)theSize bitrate:(double)theBitrate time:(double)theTime video:(BOOL)isVideo;
- (void)conversionFinished;
@end

typedef struct {
    const char *name;
    int flags;
#define HAS_ARG    0x0001
#define OPT_BOOL   0x0002
#define OPT_EXPERT 0x0004
#define OPT_STRING 0x0008
#define OPT_VIDEO  0x0010
#define OPT_AUDIO  0x0020
#define OPT_GRAB   0x0040
#define OPT_INT    0x0080
#define OPT_FLOAT  0x0100
#define OPT_SUBTITLE 0x0200
#define OPT_FUNC2  0x0400
#define OPT_INT64  0x0800
#define OPT_EXIT   0x1000
	union {
		SEL func_arg;
        int *int_arg;
        char **str_arg;
        float *float_arg;
        int64_t *int64_arg;
    } u;
    const char *help;
    const char *argname;
} OptionDef;

typedef struct AVStreamMap {
    int file_index;
    int stream_index;
    int sync_file_index;
    int sync_stream_index;
} AVStreamMap;

typedef struct AVMetaDataMap {
    int out_file;
    int in_file;
} AVMetaDataMap;

#define MAX_FILES 100

#define QSCALE_NONE -99999

#define DEFAULT_PASS_LOGFILENAME_PREFIX "ffmpeg2pass"

struct AVInputStream;

typedef struct AVOutputStream {
    int file_index;          /* file index */
    int index;               /* stream index in the output file */
    int source_index;        /* AVInputStream index */
    AVStream *st;            /* stream in the output file */
    int encoding_needed;     /* true if encoding needed for this stream */
    int frame_number;
    /* input pts and corresponding output pts
	 for A/V sync */
    //double sync_ipts;        /* dts from the AVPacket of the demuxer in second units */
    struct AVInputStream *sync_ist; /* input stream to sync against */
    int64_t sync_opts;       /* output frame counter, could be changed to some true timestamp */ //FIXME look at frame_number
    /* video only */
    int video_resample;
    AVFrame pict_tmp;      /* temporary image for resampling */
    struct SwsContext *img_resample_ctx; /* for image resampling */
    int resample_height;
    int resample_width;
    int resample_pix_fmt;
	
    /* full frame size of first frame */
    int original_height;
    int original_width;
	
    /* cropping area sizes */
    int video_crop;
    int topBand;
    int bottomBand;
    int leftBand;
    int rightBand;
	
    /* cropping area of first frame */
    int original_topBand;
    int original_bottomBand;
    int original_leftBand;
    int original_rightBand;
	
    /* padding area sizes */
    int video_pad;
    int padtop;
    int padbottom;
    int padleft;
    int padright;
	
    /* audio only */
    int audio_resample;
    ReSampleContext *resample; /* for audio resampling */
    int reformat_pair;
    AVAudioConvert *reformat_ctx;
    AVFifoBuffer *fifo;     /* for compression: one audio fifo per codec */
    FILE *logfile;
} AVOutputStream;

typedef struct AVInputStream {
    int file_index;
    int index;
    AVStream *st;
    int discard;             /* true if stream data should be discarded */
    int decoding_needed;     /* true if the packets must be decoded in 'raw_fifo' */
    int64_t sample_index;      /* current sample */
	
    int64_t       start;     /* time when read started */
    int64_t       next_pts;  /* synthetic pts for cases where pkt.pts
							  is not defined */
    int64_t       pts;       /* current pts */
    int is_start;            /* is 1 at the start and after a discontinuity */
    int showed_multi_packet_warning;
    int is_past_recording_time;
} AVInputStream;

typedef struct AVInputFile {
    int eof_reached;      /* true if eof reached */
    int ist_index;        /* index of first stream in ist_table */
    int buffer_size;      /* current total buffer size */
    int nb_streams;       /* nb streams we are aware of */
} AVInputFile;

@interface MGMFFmpeg : NSObject
#if !TARGET_OS_IPHONE
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1060)
<NSApplicationDelegate>
#endif
#endif
{
	id<MGMFFmpegDelegate> delegate;
	
	char **opt_names;
	int opt_name_count;
	AVCodecContext *avcodec_opts[AVMEDIA_TYPE_NB];
	AVFormatContext *avformat_opts;
	struct SwsContext *sws_opts;
	
	char *last_asked_format;
	AVFormatContext *input_files[MAX_FILES];
	int64_t input_files_ts_offset[MAX_FILES];
	double input_files_ts_scale[MAX_FILES][MAX_STREAMS];
	AVCodec *input_codecs[MAX_FILES*MAX_STREAMS];
	int nb_input_files;
	int nb_icodecs;
	
	AVFormatContext *output_files[MAX_FILES];
	AVCodec *output_codecs[MAX_FILES*MAX_STREAMS];
	int nb_output_files;
	int nb_ocodecs;
	
	AVStreamMap stream_maps[MAX_FILES*MAX_STREAMS];
	int nb_stream_maps;
	
	AVMetaDataMap meta_data_maps[MAX_FILES];
	int nb_meta_data_maps;
	
	int frame_width;
	int frame_height;
	float frame_aspect_ratio;
	enum PixelFormat frame_pix_fmt;
	enum SampleFormat audio_sample_fmt;
	int frame_padtop;
	int frame_padbottom;
	int frame_padleft;
	int frame_padright;
	int padcolor[3]; /* default to black */
	int frame_topBand;
	int frame_bottomBand;
	int frame_leftBand;
	int frame_rightBand;
	int max_frames[4];
	AVRational frame_rate;
	float video_qscale;
	uint16_t *intra_matrix;
	uint16_t *inter_matrix;
	char *video_rc_override_string;
	int video_disable;
	int video_discard;
	char *video_codec_name;
	int video_codec_tag;
	char *video_language;
	int same_quality;
	int do_deinterlace;
	int top_field_first;
	int me_threshold;
	int intra_dc_precision;
	int loop_input;
	int loop_output;
	int qp_hist;
	
	int intra_only;
	int audio_sample_rate;
	int64_t channel_layout;
	
	float audio_qscale;
	int audio_disable;
	int audio_channels;
	char *audio_codec_name;
	int audio_codec_tag;
	char *audio_language;
	
	int subtitle_disable;
	char *subtitle_codec_name;
	char *subtitle_language;
	int subtitle_codec_tag;
	
	float mux_preload;
	float mux_max_delay;
	
	int64_t recording_time;
	int64_t start_time;
	int64_t rec_timestamp;
	int64_t input_ts_offset;
	int metadata_count;
	AVMetadataTag *metadata;
	int do_benchmark;
	int do_hex_dump;
	int do_pkt_dump;
	int do_psnr;
	int do_pass;
	char *pass_logfilename_prefix;
	int audio_stream_copy;
	int video_stream_copy;
	int subtitle_stream_copy;
	int video_sync_method;
	int audio_sync_method;
	float audio_drift_threshold;
	int copy_ts;
	int opt_shortest;
	int video_global_header;
	char *vstats_filename;
	FILE *vstats_file;
	int opt_programid;
	int copy_initial_nonkeyframes;
	
	int rate_emu;
	
	int  video_channel;
	char *video_standard;
	
	int audio_volume;
	
	int exit_on_error;
	int verbose;
	int thread_count;
	int64_t video_size;
	int64_t audio_size;
	int64_t extra_size;
	int nb_frames_dup;
	int nb_frames_drop;
	int input_sync;
	uint64_t limit_filesize;
	int force_fps;
	
	int pgmyuv_compatibility_hack;
	float dts_delta_threshold;
	
	unsigned int sws_flags;
	
	int64_t timer_start;
	
	uint8_t *audio_buf;
	uint8_t *audio_out;
	int allocated_audio_out_size, allocated_audio_buf_size;
	
	short *samples;
	unsigned int samples_size;
	
	AVBitStreamFilterContext *video_bitstream_filters;
	AVBitStreamFilterContext *audio_bitstream_filters;
	AVBitStreamFilterContext *subtitle_bitstream_filters;
	AVBitStreamFilterContext *bitstream_filters[MAX_FILES][MAX_STREAMS];
	
#if HAVE_TERMIOS_H
	/* init terminal so that we can grab keys */
	struct termios oldtty;
#endif
	
	int bit_buffer_size;
	uint8_t *bit_buffer;
	
	int64_t last_time;
	
	int qp_histogram[52];
	
	uint8_t *subtitle_out;
	
	uint8_t *input_tmp;
	
	double previousTime;
	
	BOOL stopConverting;
#if !TARGET_OS_IPHONE
	BOOL stoppedByQuit;
#endif
	BOOL isConverting;
	
	OptionDef options[102];
}
+ (id)FFmpeg;
+ (id)FFmpegWithDelegate:(id)theDelegate;
- (id)initWithDelegate:(id)theDelegate;

- (void)setDelegate:(id)theDelegate;
- (id<MGMFFmpegDelegate>)delegate;

- (BOOL)isConverting;
- (void)stopConverting;

- (void)setOptions:(NSArray *)theOptions;
- (void)setOutputFile:(NSString *)theFile;
- (void)setOutputHandle:(NSFileHandle *)theHandle;
- (void)setInputFile:(NSString *)theFile;
- (void)setInputHandle:(NSFileHandle *)theHandle;
- (void)startConverting;

#if !TARGET_OS_IPHONE
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
#endif
@end
#endif