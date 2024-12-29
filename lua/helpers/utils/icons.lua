local M = {}

M.base = {
	abc = '  ',
	array = '  ',
	arrowReturn = '  ',
	bigCircle = '  ',
	bigUnfilledCircle = '  ',
	bookMark = '  ',
	box = '  ',
	bug = '',
	calendar = '  ',
	caretRight = '',
	check = '  ',
	checkSquare = '  ',
	exit = '  ',
	chevronRight = '',
	circle = '  ',
	class = '  ',
	close = '  ',
	code = '  ',
	cog = '  ',
	color = '  ',
	comment = '  ',
	constant = '  ',
	constructor = '  ',
	container = '  ',
	cubeTree = '  ',
	curlies = '  ',
	dashboard = '  ',
	database = ' ﬘ ',
	emptyBox = '  ',
	enum = '  ',
	enumMember = '  ',
	error = '  ',
	errorOutline = '  ',
	errorSlash = ' ﰸ ',
	event = '  ',
	f = '  ',
	field = '  ',
	file = '  ',
	fileBg = '  ',
	fileCopy = '  ',
	fileCutCorner = '  ',
	fileNoBg = '  ',
	fileNoLines = '  ',
	fileNoLinesBg = '  ',
	fileRecent = '  ',
	fire = '  ',
	folder = '  ',
	folderNoBg = '  ',
	folderOpen = '  ',
	folderOpenNoBg = '  ',
	forbidden = '  ',
	func = '  ',
	gear = '  ',
	gears = '  ',
	git = '  ',
	gitAdd = '  ',
	gitChange = ' 柳',
	gitRemove = '  ',
	happyFace = ' ﲃ ',
	hexCutOut = '  ',
	history = '  ',
	hook = ' ﯠ ',
	info = '  ',
	infoOutline = '  ',
	interface = '  ',
	keyword = '  ',
	list = '  ',
	lock = '  ',
	m = ' m ',
	method = '  ',
	module = '  ',
	newFile = '  ',
	note = '  ',
	number = '  ',
	numbers = '  ',
	object = '  ',
	operator = '  ',
	package = '  ',
	paint = '  ',
	pencil = '  ',
	pie = '  ',
	project = '  ',
	property = '  ',
	questionCircle = '  ',
	rectangleIntersect = ' 練',
	reference = '  ',
	ribbon = '  ',
	ribbonNoBg = '  ',
	robot = ' ﮧ ',
	ruler = ' 塞',
	scissors = '  ',
	scope = '  ',
	search = '  ',
	settings = '  ',
	signIn = '  ',
	sort = '  ',
	spell = ' 暈',
	squirrel = '  ',
	string = '  ',
	struct = '   ',
	t = '  ',
	table = '  ',
	tag = '  ',
	telescope = '  ',
	text = '  ',
	threeDots = '  ',
	threeDotsBoxed = '  ',
	timer = '  ',
	toggleSelected = ' 蘒',
	trash = '  ',
	treeDiagram = '  ',
	unit = '  ',
	up_hexagon = '  ',
	value = '  ',
	variable = '  ',
	vim = '  ',
	warningCircle = '  ',
	warningTriangle = '  ',
	warningTriangleNoBg = '  ',
	watch = '  ',
	wrench = '  ',
}

M.ui = {
	BookMark = ' ',
	Bomb = ' ',
	Buffer = '﬘',
	Speedometer = '⏲ ',
	Bug = ' ',
	Calendar = ' ',
	Calculator = ' ',
	Check = '',
	Circle = ' ',
	Close = '',
	Code = '',
	copilot = ' ',
	Comment = '󰅺 ',
	Dashboard = ' ',
	Fire = ' ',
	FolderOpen2 = ' ',
	Gear = ' ',
	Light = '',
	Lightbulb = '',
	LightbulbOutline = '',
	Lock = '',
	Note = '',
	Package = ' ',
	Paragraph = '',
	Pencil = '',
	Project = ' ',
	Performance = '龍',
	Search = '',
	SignIn = ' ',
	Snippet = ' ',
	Table = ' ',
	Terminal = ' ',
	ArrowCircleDown = ' ',
	ArrowCircleLeft = ' ',
	ArrowCircleRight = ' ',
	ArrowCircleUp = ' ',
	BoldArrowDown = ' ',
	BoldArrowLeft = ' ',
	BoldArrowRight = ' ',
	BoldArrowUp = ' ',
	BoldClose = '',
	BoldDividerLeft = '',
	BoldDividerRight = '',
	BoldLineLeft = '▎',
	BoxChecked = ' ',
	Stacks = ' ',
	Scopes = '',
	Watches = '',
	DebugConsole = ' ',
	ChevronRight = '>',
	ChevronShortDown = '',
	ChevronShortLeft = '',
	ChevronShortRight = '',
	ChevronShortUp = '',
	CloudDownload = ' ',
	DividerLeft = '',
	DividerRight = '',
	DoubleChevronRight = '»',
	Ellipsis = '',
	EmptyFolder = ' ',
	EmptyFolderOpen = ' ',
	File = ' ',
	FileSymlink = ' ',
	Files = ' ',
	FindFile = '',
	FindText = '',
	Folder = ' ',
	FolderOpen = ' ',
	FolderSymlink = ' ',
	Forward = ' ',
	History = ' ',
	LineLeft = '▏',
	LineMiddle = '│',
	List = ' ',
	NewFile = ' ',
	Plus = ' ',
	SignOut = ' ',
	Tab = '',
	Target = '󰀘 ',
	Telescope = ' ',
	Text = ' ',
	Tree = ' ',
	Triangle = '契',
	TriangleShortArrowDown = '',
	TriangleShortArrowLeft = '',
	TriangleShortArrowRight = '',
	TriangleShortArrowUp = '',
}

M.diagnostics = {
	Error = ' ',
	Hint = ' ',
	Information = '󰋽 ',
	Question = ' ',
	Warning = ' ',

	ErrorFilled = ' ',
	HintFilled = ' ',
	InformationFilled = ' ',
	WarningFilled = ' ',
}

M.lsp = {
	server_installed = '✓',
	server_pending = '➜',
	server_uninstalled = '✗',
}

M.git = {
	Git = '',
	Add = '', -- '',
	Branch = '', -- "",
	Diff = '',
	Ignore = '◌',
	Mod = '',
	Octoface = '',
	Remove = '', -- '',
	Rename = '➜',
	Repo = '',
	Staged = '✓', -- "S",
	Unmerged = '',
	Unstaged = '✗', -- "",
	Untracked = '★', -- "U",
	Conflict = '',
}

M.lspkind = {
	Copilot = '',
	Luasnip = '[SNP]', -- M.ui.Snippet,
	Buffer = '[BUF]', -- M.ui.Buffer,
	Nvim_lua = '[LUA]', -- M.ui.Bomb,
	Nvim_lsp_signature_help = '[SIG]',
	Calc = M.ui.Calculator,
	Path = M.ui.FolderOpen2,
	Treesitter = M.ui.Tree,
	Zsh = M.ui.Terminal,
	---
	Array = ' ',
	Boolean = '⊨',
	Constructor = ' ',
	Key = '󰌆 ',
	Namespace = ' ',
	Null = '󰟢 ',
	Number = ' ',
	Object = ' ', -- "",
	Package = ' ',
	Property = ' ',
	String = '󰉿 ',
	TypeParameter = '󰊄',
	Unit = '', -- "",
	Text = '󰉿 ',
	Function = '󰊕',
	Field = '󰜢 ',
	Variable = '󰀫', -- 󰫧
	Class = '󰠱 ',
	Interface = ' ',
	Module = ' ',
	Method = ' ',
	Value = '󰎠 ',
	Enum = ' ',
	Color = ' ',
	File = ' ',
	Reference = ' ',
	Folder = ' ',
	EnumMember = ' ',
	Struct = ' ',
	Event = '',
	Keyword = '󰌋 ',
	Snippet = ' ', --"",
	Constant = '󰏿',
	Operator = '󰆕 ',
	Macro = '󰉨 ',
}

return M
