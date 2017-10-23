#include "/settings.glsl"

//#define DOF // Currently does not take into account aperture blades

const bool colortex6MipmapEnabled = true;

//----------------------------------------------------------------------------//

// Time
uniform float frameTime;

// Viewport
uniform float aspectRatio;
uniform float viewHeight;
uniform float centerDepth;

// Samplers
uniform sampler2D colortex6; // composite
uniform sampler2D colortex7; // temporal

uniform sampler2D depthtex0;

//----------------------------------------------------------------------------//

varying vec2 screenCoord;

//----------------------------------------------------------------------------//

#include "/lib/util/constants.glsl"
#include "/lib/util/math.glsl"
#include "/lib/util/spaceConversion.glsl"

#include "/lib/uniform/gbufferMatrices.glsl"

#ifdef DOF
const vec2[335] dofOffsets = vec2[335](
	vec2(-0.4089973, -0.7511642),
	vec2(-0.3706706, -0.8872022),
	vec2(-0.4625885, -0.6738863),
	vec2(-0.5011834, -0.7404966),
	vec2(-0.2666914, -0.7975799),
	vec2(-0.4242474, -0.8247923),
	vec2(-0.3687488, -0.6332693),
	vec2(-0.1653576, -0.8734029),
	vec2(-0.2286985, -0.7087536),
	vec2(-0.2736201, -0.8993614),
	vec2(-0.5498965, -0.81714),
	vec2(-0.6369748, -0.7317436),
	vec2(-0.300704, -0.6686567),
	vec2(-0.17386, -0.7906476),
	vec2(-0.1257597, -0.6353224),
	vec2(-0.1652065, -0.5303141),
	vec2(-0.05409458, -0.6926252),
	vec2(-0.07473085, -0.502292),
	vec2(-0.005070199, -0.6148174),
	vec2(-0.7221961, -0.6191449),
	vec2(-0.6336352, -0.6300175),
	vec2(-0.6252385, -0.5511729),
	vec2(-0.5343829, -0.5641114),
	vec2(-0.7204396, -0.5128003),
	vec2(-0.5576701, -0.6865116),
	vec2(-0.5430942, -0.4592197),
	vec2(-0.4459302, -0.593269),
	vec2(-0.6429869, -0.4230418),
	vec2(-0.439233, -0.467073),
	vec2(-0.2091402, -0.6128751),
	vec2(-0.310731, -0.5434751),
	vec2(-0.04899948, -0.8703021),
	vec2(-0.08831032, -0.7679695),
	vec2(0.05376752, -0.7653183),
	vec2(0.01927419, -0.5338185),
	vec2(0.1033593, -0.6760803),
	vec2(0.117202, -0.5495874),
	vec2(-0.2502624, -0.4518182),
	vec2(0.1881297, -0.6648005),
	vec2(0.03314558, -0.8409879),
	vec2(0.1304347, -0.7910699),
	vec2(0.2152966, -0.7691222),
	vec2(0.09627321, -0.4649503),
	vec2(0.2225719, -0.5834892),
	vec2(0.1848245, -0.4167821),
	vec2(0.3185096, -0.6666784),
	vec2(0.3155495, -0.5896862),
	vec2(0.3005293, -0.4754472),
	vec2(-0.8035637, -0.4723687),
	vec2(-0.1327675, -0.9687036),
	vec2(-0.3453178, -0.7990934),
	vec2(-0.08112574, -0.4147867),
	vec2(0.01920064, -0.4041437),
	vec2(-0.1569961, -0.449642),
	vec2(0.3451598, -0.7457442),
	vec2(0.4159726, -0.6411379),
	vec2(-0.6456018, -0.3182433),
	vec2(-0.7040171, -0.3784063),
	vec2(-0.5341179, -0.3745499),
	vec2(0.04634983, -0.9521943),
	vec2(0.4278324, -0.7557755),
	vec2(0.396927, -0.8554412),
	vec2(0.3226386, -0.8206595),
	vec2(0.1958389, -0.5077968),
	vec2(-0.7504948, -0.2389199),
	vec2(-0.784381, -0.3775884),
	vec2(0.3773181, -0.516552),
	vec2(0.5479634, -0.6479248),
	vec2(0.4692522, -0.5497558),
	vec2(0.5108505, -0.4390415),
	vec2(0.1826831, -0.9261718),
	vec2(-0.542257, -0.2189141),
	vec2(-0.6225479, -0.1826808),
	vec2(-0.6731422, -0.243959),
	vec2(-0.4240563, -0.1446909),
	vec2(-0.5575832, -0.09442636),
	vec2(-0.4603867, -0.2172497),
	vec2(-0.4843543, -0.3160138),
	vec2(0.3750106, -0.3797787),
	vec2(0.5924557, -0.3996271),
	vec2(0.4859908, -0.3560757),
	vec2(0.5732177, -0.5145218),
	vec2(0.5528635, -0.3028796),
	vec2(-0.6342356, -0.05271263),
	vec2(-0.7207731, -0.1473288),
	vec2(-0.006046358, -0.3309361),
	vec2(0.1299984, -0.3478993),
	vec2(-0.3383947, -0.2187917),
	vec2(-0.3537461, -0.09698614),
	vec2(-0.4592702, -0.04642729),
	vec2(-0.4156134, -0.3900633),
	vec2(0.3089896, -0.9039807),
	vec2(0.2839392, -0.3860239),
	vec2(-0.5336954, 0.0462284),
	vec2(-0.06415106, -0.279641),
	vec2(-0.136619, -0.3352325),
	vec2(0.004879861, -0.2378974),
	vec2(0.1089196, -0.2684652),
	vec2(0.4264262, -0.2731391),
	vec2(0.5034117, -0.2091405),
	vec2(-0.7694972, -0.0480324),
	vec2(-0.7192034, 0.01683259),
	vec2(-0.151817, -0.2173001),
	vec2(-0.8564217, -0.1860486),
	vec2(0.2054206, -0.1975859),
	vec2(0.1903304, -0.3012872),
	vec2(0.157991, -0.128021),
	vec2(-0.3348981, -0.3869322),
	vec2(0.7082725, -0.3979379),
	vec2(-0.2633022, -0.2097835),
	vec2(-0.3609785, -0.2951343),
	vec2(0.6829475, -0.5505626),
	vec2(0.6374678, -0.6293569),
	vec2(-0.2606449, -0.1306308),
	vec2(0.1206483, -0.8751886),
	vec2(0.4256224, -0.1850751),
	vec2(0.3288177, -0.3166085),
	vec2(0.3322393, -0.138475),
	vec2(0.3122706, -0.2302898),
	vec2(0.5666313, -0.1640273),
	vec2(-0.2088074, -0.9491952),
	vec2(0.6142789, -0.221977),
	vec2(-0.3621981, -0.01485546),
	vec2(-0.2681495, -0.05025182),
	vec2(0.2274206, -0.8477037),
	vec2(0.6909292, -0.2878786),
	vec2(0.6794726, -0.1343735),
	vec2(0.7440203, -0.2316187),
	vec2(0.8453408, -0.3430941),
	vec2(-0.2336333, -0.2991782),
	vec2(0.6556753, -0.713439),
	vec2(0.5084077, -0.7555756),
	vec2(-0.7909119, -0.5466617),
	vec2(0.4899803, -0.06060085),
	vec2(0.5057209, -0.8478145),
	vec2(0.1999771, -0.02218653),
	vec2(0.0215941, -0.1072074),
	vec2(0.2739128, -0.08424668),
	vec2(0.3868507, -0.06337885),
	vec2(0.8735561, -0.2170291),
	vec2(0.7887475, -0.1540539),
	vec2(-0.432809, 0.02750538),
	vec2(-0.3315461, 0.06607072),
	vec2(-0.1537013, -0.1046233),
	vec2(-0.1646122, 0.02546974),
	vec2(0.5781232, 0.02142988),
	vec2(0.4447311, 0.03890404),
	vec2(0.511644, 0.08131048),
	vec2(0.6428511, -0.02373168),
	vec2(-0.6190236, 0.06144157),
	vec2(-0.6716596, 0.1312115),
	vec2(-0.8195812, 0.01962696),
	vec2(0.578851, -0.7874212),
	vec2(-0.4154996, 0.107281),
	vec2(-0.5052389, 0.1429285),
	vec2(0.8020595, -0.4220779),
	vec2(0.07011297, -0.1906306),
	vec2(0.662102, 0.05574728),
	vec2(0.7571917, 0.04140291),
	vec2(0.7765962, -0.04438493),
	vec2(-0.8972183, -0.4221751),
	vec2(0.8309057, 0.1171907),
	vec2(0.7529933, 0.1682002),
	vec2(0.8296379, 0.0104663),
	vec2(0.5778617, 0.1519118),
	vec2(-0.2275473, 0.07193782),
	vec2(-0.05191146, -0.1616785),
	vec2(0.454924, 0.1591279),
	vec2(0.3035537, 0.04464481),
	vec2(0.6806953, 0.1990635),
	vec2(0.7369545, -0.6514588),
	vec2(0.6666772, -0.4726834),
	vec2(-0.02729961, -0.04729487),
	vec2(0.06216265, 0.01130534),
	vec2(-0.9225171, -0.1244247),
	vec2(-0.8027077, -0.2985812),
	vec2(-0.8120636, -0.1185454),
	vec2(-0.9381195, -0.2467727),
	vec2(0.8921679, 0.07058525),
	vec2(0.3793271, 0.08221895),
	vec2(0.4769539, 0.2891059),
	vec2(0.3601896, 0.1860187),
	vec2(-0.5780693, 0.1248237),
	vec2(0.8076435, 0.2381532),
	vec2(0.7465301, 0.3011695),
	vec2(-0.1238381, 0.1101768),
	vec2(-0.1942909, 0.1604647),
	vec2(-0.07350492, 0.02163101),
	vec2(-0.9232363, -0.3400832),
	vec2(0.535757, 0.2377974),
	vec2(0.6006157, 0.2905585),
	vec2(-0.884718, 0.09909204),
	vec2(-0.7882625, 0.1070366),
	vec2(-0.9313017, -0.02082942),
	vec2(0.8544668, -0.4969417),
	vec2(-0.4445856, 0.2407675),
	vec2(0.8741944, 0.3002482),
	vec2(0.9493778, 0.2331378),
	vec2(0.9004026, 0.1638975),
	vec2(0.9404901, -0.2767293),
	vec2(0.9727095, -0.175354),
	vec2(-0.4250382, 0.3725836),
	vec2(-0.369313, 0.200526),
	vec2(-0.5342911, 0.3479034),
	vec2(0.8897754, -0.1283739),
	vec2(0.7667687, 0.3832336),
	vec2(0.4377461, 0.3750124),
	vec2(0.1270924, -0.04871088),
	vec2(0.9059937, -0.4084639),
	vec2(-0.621834, 0.2250199),
	vec2(-0.6035691, 0.3787676),
	vec2(-0.5193558, 0.4708591),
	vec2(-0.962775, 0.07417183),
	vec2(0.9768624, 0.1337258),
	vec2(0.9217993, 0.3592892),
	vec2(0.19187, 0.06073318),
	vec2(0.3402933, 0.3732835),
	vec2(0.3096753, 0.4459227),
	vec2(0.4239687, 0.461411),
	vec2(0.9862729, -0.07355265),
	vec2(0.9706489, 0.05798709),
	vec2(0.6697075, 0.3265947),
	vec2(0.6678831, 0.4201364),
	vec2(-0.7387857, 0.2432778),
	vec2(0.8467515, 0.4775541),
	vec2(0.719951, 0.5133385),
	vec2(-0.62527, 0.4665879),
	vec2(-0.4200404, 0.5137489),
	vec2(-0.4974403, 0.5713489),
	vec2(-0.6394172, 0.5467868),
	vec2(-0.5860732, 0.6020677),
	vec2(-0.3576669, 0.5888227),
	vec2(-0.8154618, 0.218564),
	vec2(-0.8020419, 0.3671885),
	vec2(-0.6799089, 0.3321379),
	vec2(0.7880703, -0.5587353),
	vec2(0.1673844, 0.1818091),
	vec2(-0.3516933, 0.3265341),
	vec2(-0.2631409, 0.2149844),
	vec2(-0.2567894, 0.2982629),
	vec2(-0.8741854, 0.299532),
	vec2(0.5331184, 0.4324297),
	vec2(0.6410266, 0.4961166),
	vec2(-0.09055632, 0.2669208),
	vec2(-0.9584865, 0.200953),
	vec2(-0.3627744, 0.6871212),
	vec2(-0.2550202, 0.5852929),
	vec2(-0.3320238, 0.472865),
	vec2(-0.2627764, 0.6677808),
	vec2(-0.1887452, 0.7481632),
	vec2(-0.1398379, 0.6242816),
	vec2(-0.03710975, 0.08866639),
	vec2(-0.8626941, 0.4149004),
	vec2(-0.7189534, 0.6311453),
	vec2(-0.5746841, 0.7513525),
	vec2(-0.1894431, 0.2652391),
	vec2(-0.2620005, 0.3993761),
	vec2(0.2097313, 0.4518485),
	vec2(0.2345676, 0.3283361),
	vec2(0.2717547, 0.5385514),
	vec2(-0.803591, 0.5170645),
	vec2(-0.7061704, 0.5046546),
	vec2(-0.631146, 0.6883162),
	vec2(0.627381, 0.6135746),
	vec2(-0.5041264, 0.6687174),
	vec2(-0.4994147, 0.8524835),
	vec2(-0.05877936, 0.1617979),
	vec2(0.6761503, 0.6911301),
	vec2(0.7201995, 0.6033074),
	vec2(0.5490664, 0.7294738),
	vec2(0.4963042, 0.6557845),
	vec2(-0.2884791, 0.8094112),
	vec2(-0.409701, 0.7471547),
	vec2(0.1394852, 0.3648247),
	vec2(0.3629778, 0.2916399),
	vec2(0.2391618, 0.2293903),
	vec2(-0.1504865, 0.3657208),
	vec2(-0.1305489, 0.2017026),
	vec2(0.1666872, 0.2815197),
	vec2(-0.2333135, 0.5127207),
	vec2(-0.6965029, 0.4239031),
	vec2(0.5254416, 0.5710388),
	vec2(0.5254862, 0.3463594),
	vec2(0.3473747, 0.5480943),
	vec2(0.01512463, 0.1435153),
	vec2(-0.03136262, 0.3296864),
	vec2(0.6149659, 0.7868136),
	vec2(0.4381656, 0.7149414),
	vec2(0.541504, 0.8090525),
	vec2(-0.4254958, 0.633003),
	vec2(0.06308945, 0.2597087),
	vec2(0.9124427, -0.05586414),
	vec2(-0.09736809, 0.5167082),
	vec2(-0.193058, 0.4442572),
	vec2(-0.4090672, 0.8666837),
	vec2(-0.09323161, 0.4172481),
	vec2(0.04345229, 0.3410575),
	vec2(0.2850043, 0.6538559),
	vec2(0.3994265, 0.6260657),
	vec2(0.4661375, 0.7984608),
	vec2(-0.1084896, 0.8556175),
	vec2(-0.2018579, 0.8741899),
	vec2(-0.06757835, 0.7537063),
	vec2(0.1416707, 0.5261325),
	vec2(-0.7725075, 0.4442846),
	vec2(0.4149357, 0.8694571),
	vec2(-0.01045621, 0.453146),
	vec2(0.7688726, -0.3482856),
	vec2(-0.02467104, 0.9645121),
	vec2(0.02191843, 0.810385),
	vec2(-0.1943032, 0.9780709),
	vec2(-0.4810762, 0.7756628),
	vec2(0.05255856, 0.6911858),
	vec2(0.2542018, 0.129319),
	vec2(-0.04009083, 0.6481699),
	vec2(0.2021882, 0.5766054),
	vec2(0.3124321, 0.9008943),
	vec2(-0.2801055, 0.9276586),
	vec2(0.03187552, 0.5240378),
	vec2(-0.7940947, 0.6059845),
	vec2(0.04217583, 0.6169056),
	vec2(0.159982, 0.6417317),
	vec2(0.2039738, 0.7036753),
	vec2(0.06558172, 0.4223694),
	vec2(0.09969611, 0.9348852),
	vec2(0.1499306, 0.8366365),
	vec2(0.229968, 0.8136165),
	vec2(-0.1141663, 0.9334862),
	vec2(-0.5612749, 0.2713875),
	vec2(-0.9440274, 0.3290866),
	vec2(0.3507158, 0.6997426),
	vec2(0.09139924, 0.7617144),
	vec2(0.215538, 0.9596841),
	vec2(0.01578938, 0.8897761),
	vec2(0.2944782, 0.7678619)
);

vec3 depthOfField() {
	const float aperture = APERTURE_RADIUS;
	      float focal    = abs(aperture * projection[0].x);

	float depth = abs(linearizeDepth(texture2D(depthtex0, screenCoord).r, projectionInverse));
	float focus = abs(linearizeDepth(texture2D(depthtex0, vec2(0.5)).r, projectionInverse));

	vec2 circleOfConfusion = aperture * focal * abs(depth - focus) / (depth * abs(focus - focal) * vec2(aspectRatio, 1.0));

	float lod = log2(2.0 * viewHeight * circleOfConfusion.y / sqrt(dofOffsets.length()) + 1.0);

	vec3 result = vec3(0.0);
	for (int i = 0; i < dofOffsets.length(); i++) {
		result += texture2DLod(colortex6, dofOffsets[i] * circleOfConfusion + screenCoord, lod).rgb;
	}
	return result / dofOffsets.length();
}
#endif

float calculateSmoothLuminance() {
	float prevLuminance = texture2D(colortex7, screenCoord).r;
	float currLuminance = clamp(dot(texture2DLod(colortex6, vec2(0.5), 100).rgb, lumacoeff_rec709) / (0.35 / prevLuminance), 20.0, 2e4);

	if (prevLuminance == 0.0) prevLuminance = 0.35;

	return mix(prevLuminance, currLuminance, frameTime / (1.0 + frameTime));
}

void main() {
	#ifdef DOF
	vec3 color = depthOfField();
	#else
	vec3 color = texture2D(colortex6, screenCoord).rgb;
	#endif

/* DRAWBUFFERS:637 */

	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(calculateSmoothLuminance());
	gl_FragData[2] = texture2D(colortex7, screenCoord);
}
