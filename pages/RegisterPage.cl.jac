"""Register page component — AnyGPT orange theme."""

import from react { useEffect }
import from "@jac/runtime" { Link, useNavigate, jacIsLoggedIn }
import from "@mantine/core" {
    Box,
    Paper,
    Text,
    TextInput,
    PasswordInput,
    Button,
    Stack,
    Group,
    Anchor,
    Alert
}
import from "@tabler/icons-react" {
    IconUser,
    IconLock,
    IconMail,
    IconAlertCircle,
    IconSparkles
}
import from ..hooks.useAuth { useAuth }


def:pub RegisterPage() -> any {
    hook = useAuth();
    navigate = useNavigate();

    username = hook.username;
    password = hook.password;
    confirmPassword = hook.confirmPassword;
    email = hook.email;
    error = hook.error;
    loading = hook.loading;

    ORANGE = "#FF6B35";
    ORANGE_DARK = "#E85D2C";
    TEXT = "#1A1A1A";
    MUTED = "#6B7280";
    BORDER = "#F0F0F0";
    BG = "#FFFFFF";
    SURFACE = "#F9F9F9";

    # Redirect if already logged in
    useEffect(lambda -> None {
        if jacIsLoggedIn() {
            navigate("/");
        }
    }, []);

    errorDisplay = None;
    if error {
        errorDisplay = <Alert
            icon={<IconAlertCircle size={16} />}
            color="red"
            variant="light"
            mb="md"
            styles={{
                "root": {
                    "background": "rgba(239, 68, 68, 0.06)",
                    "border": "1px solid rgba(239, 68, 68, 0.2)"
                },
                "message": {"color": "#dc2626"}
            }}
        >
            {error}
        </Alert>;
    }

    return <Box style={{
        "minHeight": "100vh",
        "background": "linear-gradient(135deg, #FFF5F0 0%, #FFFFFF 50%, #FFF5F0 100%)",
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "center",
        "padding": "20px"
    }}>
        <Paper
            p="xl"
            radius="lg"
            style={{
                "width": "100%",
                "maxWidth": "420px",
                "background": BG,
                "border": "1px solid " + BORDER,
                "boxShadow": "0 20px 60px rgba(0,0,0,0.06)"
            }}
        >
            <Stack gap="lg">
                <Box ta="center">
                    <Box style={{
                        "width": "64px",
                        "height": "64px",
                        "margin": "0 auto 16px",
                        "borderRadius": "16px",
                        "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "boxShadow": "0 8px 28px rgba(255,107,53,0.25)"
                    }}>
                        <IconSparkles size={28} color="#ffffff" />
                    </Box>

                    <Text size="xl" fw={700} c={TEXT} mb={4}>
                        Create Account
                    </Text>
                    <Text size="sm" c={MUTED}>
                        Join AnyGPT to start exploring your documents
                    </Text>
                </Box>

                <form onSubmit={hook.handleRegister}>
                    <Stack gap="md">
                        <TextInput
                            label="Username"
                            placeholder="Choose a username"
                            value={username}
                            onChange={hook.handleUsernameChange}
                            disabled={loading}
                            leftSection={<IconUser size={16} />}
                            autoComplete="username"
                            styles={{
                                "label": {"color": TEXT, "marginBottom": "6px", "fontWeight": "500"},
                                "input": {
                                    "background": SURFACE,
                                    "border": "1px solid " + BORDER,
                                    "color": TEXT
                                }
                            }}
                        />

                        <TextInput
                            label="Email"
                            placeholder="Enter your email"
                            value={email}
                            onChange={hook.handleEmailChange}
                            disabled={loading}
                            leftSection={<IconMail size={16} />}
                            autoComplete="email"
                            styles={{
                                "label": {"color": TEXT, "marginBottom": "6px", "fontWeight": "500"},
                                "input": {
                                    "background": SURFACE,
                                    "border": "1px solid " + BORDER,
                                    "color": TEXT
                                }
                            }}
                        />

                        <PasswordInput
                            label="Password"
                            placeholder="Create a password (min 6 chars)"
                            value={password}
                            onChange={hook.handlePasswordChange}
                            disabled={loading}
                            leftSection={<IconLock size={16} />}
                            autoComplete="new-password"
                            styles={{
                                "label": {"color": TEXT, "marginBottom": "6px", "fontWeight": "500"},
                                "input": {
                                    "background": SURFACE,
                                    "border": "1px solid " + BORDER,
                                    "color": TEXT
                                }
                            }}
                        />

                        <PasswordInput
                            label="Confirm Password"
                            placeholder="Confirm your password"
                            value={confirmPassword}
                            onChange={hook.handleConfirmPasswordChange}
                            disabled={loading}
                            leftSection={<IconLock size={16} />}
                            autoComplete="new-password"
                            styles={{
                                "label": {"color": TEXT, "marginBottom": "6px", "fontWeight": "500"},
                                "input": {
                                    "background": SURFACE,
                                    "border": "1px solid " + BORDER,
                                    "color": TEXT
                                }
                            }}
                        />

                        {errorDisplay}

                        <Button
                            type="submit"
                            fullWidth
                            loading={loading}
                            size="md"
                            mt="xs"
                            styles={{
                                "root": {
                                    "background": "linear-gradient(135deg, " + ORANGE + " 0%, " + ORANGE_DARK + " 100%)",
                                    "border": "none",
                                    "boxShadow": "0 4px 14px rgba(255,107,53,0.25)"
                                }
                            }}
                        >
                            {(("Creating account..." if loading else "Create Account"))}
                        </Button>
                    </Stack>
                </form>

                <Group justify="center">
                    <Text size="sm" c={MUTED}>
                        Already have an account?
                    </Text>
                    <Anchor
                        component={Link}
                        to="/login"
                        size="sm"
                        fw={600}
                        style={{"color": ORANGE}}
                    >
                        Sign in
                    </Anchor>
                </Group>
            </Stack>
        </Paper>
    </Box>;
}
