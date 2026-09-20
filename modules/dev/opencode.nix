{
  flake.modules.nixos.opencode = { pkgs, ... }: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      loadModels = [
        "qwen2.5-coder:7b"
      ];
    };
  };

  flake.modules.homeManager.opencode = {
    programs.opencode = {
      enable = true;
      settings = {
        model = "anthropic/claude-sonnet-4-6";
        autoupdate = false;
        permission = {
          edit = "ask";
          bash = "ask";
        };
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options.baseURL = "http://localhost:11434/v1";
          models."qwen2.5-coder:7b" = {
            name = "qwen2.5-coder:7b";
          };
        };
      };

      agents = {
        code-reviewer = ''
          # Code Reviewer Agent

          You are a senior software engineer specializing in code reviews.
          Focus on code quality, security, and maintainability.

          ## Guidelines
          - Review for potential bugs and edge cases
          - Check for security vulnerabilities
          - Ensure code follows best practices
          - Suggest improvements for readability and performance
        '';
      };
    };
  };
}
